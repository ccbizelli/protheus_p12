#include 'protheus.ch'
#include 'parmtype.ch'

#define Pula chr(13) + chr(10)

/*/{Protheus.doc} M0000007
Função responsável pela comparação e atualização entre duas estruturas SX2
@author ciro.chagas
@since 22/03/2017
@version undefined

@type function
/*/
user function M0000007()
	
	Private	cBaseOrig		:= "sx2000"
	Private	cAliasOrig		:= GetNextAlias()
	Private	cBaseDest		:= "sx2000_p12"
	Private	cAliasDest		:= GetNextAlias()
	Private	cExtensao		:= ".dbf"
	Private	cArquivo		:= GetTempPath() + DToS(Date()) + StrTran(Time(),":","")+".xml"
	Private	aSX2			:= {}
	Private	cIndexKey		:= "X2_CHAVE"
	
	Processa({|| comparaSX2()},"Varrendo SX2...","Gerando informações SX2 divergentes...",.T.)
	
	If len(aSX2) > 0
		If MsgYesNo("Prosseguir com o update da(s) " + cValToChar(len(aSX2)) + " tabela(s)?")
				
			Processa({|| atualizaSX2(aSX2)},"Aguarde...","Atualizando registros...")
				
		Else
			
			MsgInfo("Operação cancelada pelo operador.")
				
		EndIf
	Else
		MsgInfo("Nenhuma tabela divergente.")
	EndIf
	
Return nil

/*/{Protheus.doc} comparaSX2
Função responsável por gerar excel as divergências entre duas SX2 quando as mesmas existirem tabelas no SQL e com registros > 0
@author ciro.chagas
@since 22/03/2017
@version undefined

@type function
/*/
Static function comparaSX2()

	Local	cArea		:= GetArea()
	Local	cTExis		:= GetNextAlias()
	Local	cTReg		:= GetNextAlias()
	Local	cTable		:= ""
	Local	nReg		:= 0
	Local	cQuery		:= ""
	Local	cExiste	
	Local	nCount		:= 0
	Local	cWorkSheet	:= "Relação SX2"
	Local	cTabela		:= "Tabelas divergentes P11 x P12"
		
	Local	cCol01		:= "Chave - X2_CHAVE"
	Local	cCol02		:= "Nome - X2_NOME"
	Local	cCol03		:= "Qtd. Registros por Tabela"
	Local	cCol04		:= "P12 Arquivo -  X2_ARQUIVO"
	Local	cCol05		:= "P12 Comp. Empresa - X2_MODOEMP"
	Local	cCol06		:= "P12 Comp. Unid. Negócio - X2_MODOUN"
	Local	cCol07		:= "P12 Comp. Filial - X2_MODO"
	Local	cCol08		:= "P11 Arquivo -  X2_ARQUIVO"
	Local	cCol09		:= "P11 Comp. Empresa - X2_MODOEMP"
	Local	cCol10		:= "P11 Comp. Unid. Negócio - X2_MODOUN"
	Local	cCol11		:= "P11 Comp. Filial - X2_MODO"
	
	Local	cIndexName	:= Criatrab(nil,.F.)
	
	Local	oFWMsExcel
	Local	oExcel	
	
	oFWMsExcel	:= FWMSExcel():New()
		
	dbUseArea( .T.,__LOCALDRIVER,cBaseOrig + cExtensao,cAliasOrig,.T.,.F.)
		 		
	dbUseArea( .T.,__LOCALDRIVER,cBaseDest + cExtensao,cAliasDest,.T.,.F.)
	//Seto indice temporário para uso no dbSeek
	IndRegua(cAliasDest,cIndexName,cIndexKey)
	(cAliasDest)->( dbSetIndex(cIndexName + OrdBagExt()) ) 		
	
	oFWMsExcel:AddWorkSheet(cWorkSheet)
		oFWMsExcel:AddTable(cWorkSheet,cTabela)
			oFWMsExcel:AddColumn(cWorkSheet,cTabela,cCol01,1,1,.F.)
			oFWMsExcel:AddColumn(cWorkSheet,cTabela,cCol02,1,1,.F.)
			oFWMsExcel:AddColumn(cWorkSheet,cTabela,cCol03,1,2,.F.)
			oFWMsExcel:AddColumn(cWorkSheet,cTabela,cCol04,1,1,.F.)
			oFWMsExcel:AddColumn(cWorkSheet,cTabela,cCol05,1,1,.F.)
			oFWMsExcel:AddColumn(cWorkSheet,cTabela,cCol06,1,1,.F.)
			oFWMsExcel:AddColumn(cWorkSheet,cTabela,cCol07,1,1,.F.)
			oFWMsExcel:AddColumn(cWorkSheet,cTabela,cCol08,1,1,.F.)
			oFWMsExcel:AddColumn(cWorkSheet,cTabela,cCol09,1,1,.F.)
			oFWMsExcel:AddColumn(cWorkSheet,cTabela,cCol10,1,1,.F.)
			oFWMsExcel:AddColumn(cWorkSheet,cTabela,cCol11,1,1,.F.)

	While ! (cAliasOrig)->(EoF())
		
		If (cAliasDest)->(dbSeek((cAliasOrig)->X2_CHAVE))
			
			cTable	:= (cAliasOrig)->X2_CHAVE
			
			cQuery := " SELECT CASE WHEN COUNT(*) > 0 THEN 'SIM' ELSE 'NAO' END EXISTE FROM sys.objects WHERE OBJECT_ID = OBJECT_ID(N'"+cTable+"000') AND TYPE IN (N'U') "
			
			dbUseArea(.T., "TOPCONN", TCGenQry(, , cQuery), cTExis, .F., .F.)
			
			dbSelectArea(cTExis)
			cExiste	:= (cTExis)->EXISTE
			(cTExis)->(dbCloseArea())
			
			//Na query acima, valido se a tabela existe no SQL, se si
			If Upper(cExiste) == "SIM"
			
				cQuery	:= " SELECT COUNT(*) REGISTROS FROM " + cTable + "000 "
				dbUseArea(.T., "TOPCONN", TCGenQry(, , cQuery), cTReg, .F., .F.)
				nReg	:= 0
				dbSelectArea(cTReg)
				nReg	:= (cTReg)->REGISTROS
				(cTReg)->(dbCloseArea())
				
				//Valido se existe registros na tabela					
				If nReg > 0
					If 	((cAliasDest)->X2_MODO <> (cAliasOrig)->X2_MODO) .or. ((cAliasDest)->X2_MODOUN <> (cAliasOrig)->X2_MODOUN) .or. ((cAliasDest)->X2_MODOEMP <> (cAliasOrig)->X2_MODOEMP) .or. (AllTrim((cAliasDest)->X2_ARQUIVO) <> AllTrim((cAliasOrig)->X2_ARQUIVO))
						
						oFWMsExcel:AddRow(cWorkSheet,cTabela,{	AllTrim((cAliasDest)->X2_CHAVE),;
																AllTrim(Upper((cAliasDest)->X2_NOME)),;
																cValToChar(nReg),;
																AllTrim((cAliasDest)->X2_ARQUIVO),;
																IIf((cAliasDest)->X2_MODOEMP = "E","Exclusivo",IIf((cAliasDest)->X2_MODOEMP = "C","Compartilhada","Vazio")),;
																IIf((cAliasDest)->X2_MODOUN = "E","Exclusivo",IIf((cAliasDest)->X2_MODOUN = "C","Compartilhada","Vazio")),;
																IIf((cAliasDest)->X2_MODO = "E","Exclusivo",IIf((cAliasDest)->X2_MODO = "C","Compartilhada","Vazio")),; 
																AllTrim((cAliasOrig)->X2_ARQUIVO),;
																IIf((cAliasOrig)->X2_MODOEMP = "E","Exclusivo",IIf((cAliasOrig)->X2_MODOEMP = "C","Compartilhada","Vazio")),;
																IIf((cAliasOrig)->X2_MODOUN = "E","Exclusivo",IIf((cAliasOrig)->X2_MODOUN = "C","Compartilhada","Vazio")),;
																IIf((cAliasOrig)->X2_MODO = "E","Exclusivo",IIf((cAliasOrig)->X2_MODO = "C","Compartilhada","Vazio"));
																})
						aAdd(aSX2,{(cAliasOrig)->X2_CHAVE,(cAliasOrig)->X2_ARQUIVO,(cAliasOrig)->X2_MODOEMP,(cAliasOrig)->X2_MODOUN,(cAliasOrig)->X2_MODO})	
															
						nCount++
						
					EndIf
				EndIf
			EndIf
		EndIf
					
		(cAliasOrig)->(dbSkip())
		
	EndDo	

	oFWMsExcel:Activate()
	oFWMsExcel:GetXMLFile(cArquivo)

	oExcel	:= MsExcel():New()		
	oExcel:WorkBooks:Open(cArquivo)	
	oExcel:SetVisible(.T.)			
	oExcel:Destroy()					
		
	MsgInfo("Diretório do arquivo: " +; 
			Pula +; 
			cArquivo +;
			Pula +;
			cValToChar(nCount) + " tabela(s).")
	
	(cAliasDest)->(dbCloseArea())
	(cAliasOrig)->(dbCloseArea())
	
	RestArea(cArea)
	
Return nil

/*/{Protheus.doc} atualizaSX2
Função responsável em atualizar SX2 destino conforme origem
@author ciro.chagas
@since 22/03/2017
@version undefined
@param aTabelas, array, descricao
@type function
/*/
Static function atualizaSX2(aTabelas)

	Local	cArea		:= GetArea()
	Local	cAliasUpd	:= GetNextAlias()
	Local	nX			:= 0
	Local	lGravou		:= .F.
	Local	cIndexName	:= Criatrab(nil,.F.)
	
	Default aTabelas	:= {}
	
	dbUseArea( .T.,__LOCALDRIVER,cBaseDest + cExtensao,cAliasUpd,.T.,.F.)
	IndRegua(cAliasUpd,cIndexName,cIndexKey)
	(cAliasUpd)->(dbSetIndex(cIndexName + OrdBagExt()))
		
	Begin Transaction
	
		for nX:= 1 to Len(aTabelas)

			If (cAliasUpd)->(dbSeek(aTabelas[nX][1]))
				
				If RecLock(cAliasUpd, .F.)
				
					X2_ARQUIVO	:= aTabelas[nX][2]
					X2_MODOEMP	:= aTabelas[nX][3]
					X2_MODOUN	:= aTabelas[nX][4]
					X2_MODO		:= aTabelas[nX][5]
					
					lGravou	:= .T.
							
				Else 
					
					lGravou	:= .F.
					DisarmTransaction()
					Exit				
				EndIf
				
			Else
				
				lGravou	:= .F.
				DisarmTransaction()
				Exit	
				
			EndIf
			
		next
	End Transaction
	
	If lGravou
	
		MsgInfo("Alteração realizada com sucesso na(s) " + cValToChar(len(aTabelas)) + " tabela(s).")
		
	Else
		
		MsgStop("Gravação abortada devido falha no processo.")
		
	EndIf
	
	(cAliasUpd)->(dbCloseArea())
	RestArea(cArea)
		
Return nil