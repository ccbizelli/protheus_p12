#include 'totvs.ch'

/*/{Protheus.doc} G0400003
Gatilho para inserção de código automático na B1
@author ciro.chagas
@since 09/03/2017
@version undefined
@param cTipo, characters, Tipo do Aliás, se B1 ou se Grade
@type function
/*/
user function G0400003(cTipo)

	Local	aArea	:= GetArea()
	
	Local	cCodPai	:= ""
	Local	cFirstU	:= ""
	Local	cSegun	:= ""
	Local	cSequen	:= ""
	
	Local	cCod
	
	/*
	Novas Regras definidas dia 09-03-17
	Retirar segmento da codificação
	Código pai dentro do Código do Produto
	Retirar grupo da codificação
	Não terá filho bastardo, ou é pai ou é filho
	Retirar BM_TIPGRU como obrigatório
	*/

	If cTipo = "SB1"
				
		cCodPai		:= M->B1_XCODPAI 											//05
		cFirstU		:= M->B1_UM													//02
		cSegun		:= PADL(StrTran(cValToChar(M->B1_CONV),".",""),5,"0")		//05
		cSequen		:= FRETSEQ(cCodPai,cFirstU,M->B1_CONV,cSequen)				//02
		
		cCod		:=	cCodPai+cFirstU+cSegun+"."+cSequen						//15
		
	/* Else
		
		cGrupo		:= M->B4_GRUPO												//04	
		cTipGrup	:= Posicione("SBM",1,FWxFilial("SBM")+cGrupo,"BM_TIPGRU")	//02
		cFirstU		:= M->B4_UM													//02
		cSegun		:= PADL(StrTran(cValToChar(M->B4_CONV),".",""),5,"0")		//05
		
		//Código de retorno da Grade de Produtos diferencia-se do Código do Produto pois, neste campo tratamos apenas 11 casas, 
		//as demais 4 casas são gravadas de forma padrão, de acordo com a Tabela Linha + Tabela Colun
		cCod		:=	cTipGrup+cGrupo+cFirstU+cSegun							//11
	*/
		
	EndIf
	*/
	

	RestArea(aArea)
	
Return cCod

/*/{Protheus.doc} FRETSEQ
Função que retorna as 4 últimas posições do B1_COD sequênciando com Soma1 de String, caso seja o primeiro registro, retorna 0000
@author ciro.chagas 
@since 09/03/2017
@version undefined
@param cGrupo, characters, descricao
@param cTipGrup, characters, descricao
@param cFirstU, characters, descricao
@param cSegun, characters, descricao
@param cSequen, characters, descricao
@type function
/*/
Static Function FRETSEQ(cCodPai,cFirstU,cSegun,cSequen)

	Local	cSequen	:= "00"
	Local	xAlias	:= GetNextAlias()
	Local	nCount	:= 0
	
	BeginSql Alias xAlias
		Select
			max(substring(B1_COD,14,2))	SEQATU
		From
			%table:SB1% SB1
		Where
			SB1.%notDel%
			AND	B1_XCODPAI	= %Exp:cCodPai%
			AND	B1_UM		= %Exp:cFirstU%
			AND	B1_CONV		= %Exp:cSegun%
	EndSql
	
	dbSelectArea(xAlias)
	(xAlias)->(dbGoTop())
	(xAlias)->(dbEval({||nCount++}))
	(xAlias)->(dbGoTop())
	
	If ! Empty(nCount)
		While !(xAlias)->(EoF())
			
			cSequen	:= Soma1((xAlias)->SEQATU)
			
			(xAlias)->(dbSkip())
			
		EndDo
	EndIf
	
	(xAlias)->(dbCloseArea())
	
Return	cSequen