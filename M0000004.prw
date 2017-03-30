#include 'protheus.ch'
#include 'parmtype.ch'

/*/{Protheus.doc} M0000004
Função M0000004 genérica
@author ciro.chagas
@since 09/03/2017
@version undefined

@type function
/*/

User Function M0000004()

Return nil

User Function Saudacao()

	Local cSaudacao := ''
	
	If Val(SubStr(Alltrim(Time()),1,2)) < 12
		cSaudacao := "Bom dia"
	ElseIf Val(SubStr(Alltrim(Time()),1,2)) >= 12 .and. Val(SubStr(Alltrim(Time()),1,2)) < 18
		cSaudacao := "Boa tarde"
	ElseIf Val(SubStr(Alltrim(Time()),1,2)) >= 18
		cSaudacao := "Boa noite"
	EndIf
	
	cSaudacao += ' ' + Alltrim(SubStr(cUsuario,7,At(' ',cUsuario)-7))
	
Return cSaudacao

/*/{Protheus.doc} FS_COSLDB8
Função genérica para consultar o saldo do produto por lote, podendo ser por filial ou geral, dependendo de sua chamada
@author ciro.chagas
@since 22/03/2017
@version undefined
@param cFil, characters, descricao
@param cCod, characters, descricao
@type function
/*/
Static function FS_COSLDB8(cFil,cCod)

	Local	nRet	:= 0
	Local	cArea	:= GetArea()
	Local	xAlias	:= GetNextAlias()
	
	Default cFil	:= ""
	Default	cCod	:= ""

	BeginSql Alias xAlias
		Select
			B8_FILIAL, SUM(B8_SALDO) B8_SALDO
		From
			%table:SB8% SB8
		Where
			SB8.%notDel%
			AND	B8_PRODUTO	= %Exp:cCod%
		Group by B8_FILIAL
	EndSql
	
	dbSelectArea(xAlias)
	(xAlias)->(dbGoTop())
	
	While !(xAlias)->(EoF())
		
		If ! Empty(cFil)
			
			If (xAlias)->B8_FILIAL = cFil
			
				nRet	+= (xAlias)->B8_SALDO
		
			EndIf
		Else
			
			nRet	+= (xAlias)->B8_SALDO
			
		EndIf
		
		(xAlias)->(dbSkip())
		
	EndDo
		
	(xAlias)->(dbCloseArea())
	
	RestArea(cArea)
	
return nRet


/*/{Protheus.doc} FS_MOVPROD
Função genérica que retorna .T. caso o produto já tenha sido movimentado (d1, d2, d3)
@author ciro.chagas
@since 23/03/2017
@version undefined
@param cCod, characters, descricao
@type function
/*/
Static function FS_MOVPROD(cCod)

	Local	lRet	:= .F.
	Local	cArea	:= GetArea()
	Local	xAlias	:= GetNextAlias()
	
	Default cFil	:= ""
	Default	cCod	:= ""

	BeginSql Alias xAlias
		Select sum(count) count
		From
			(
			Select count(*) count from %table:SD1% SD1 where D1_COD = %Exp:cCod%
			union all
			Select count(*) count from %table:SD2% SD2 where D2_COD = %Exp:cCod%
			union all
			Select count(*) count from %table:SD3% SD3 where D3_COD = %Exp:cCod%
			) x
	EndSql
	
	dbSelectArea(xAlias)
	(xAlias)->(dbGoTop())
	
	If (xAlias)->count > 0
	
		lRet	:= .T.
		
	EndIf
		
	(xAlias)->(dbCloseArea())

	RestArea(cArea)
	
return lRet

/*/{Protheus.doc} FS_PROCFIL
Função que checa se há produtos Filho vinculados ao código pai
@author ciro.chagas
@since 23/03/2017
@version undefined
@param cPai, characters, descricao
@type function
/*/
Static function FS_PROCFIL(cPai)

	Local	lRet	:= .F.
	Local	cArea	:= GetArea()

	dbSelectArea("SB1")
	SB1->(DBOrderNickName("CODPAI"))
	
	lRet	:= SB1->(dbSeek(cPai))

	RestArea(cArea)
return lRet

/*/{Protheus.doc} TemAcesso
//TODO Verifica se o usuario tem acesso a um determinado grupo cadastrado na Z05 e Z03.
@author paulo.siqueira
@since 30/03/2017
@version undefined
@param cGrupo, characters, descricao
@type function
/*/
Static function TemAcesso(cGrupo)

	Local lRet 		:= .F.
	Local aArea 	:= GetArea()
	Local cCodUsr 	:= __CUSERID
	Local cAlsUs 	:= GetNextAlias()
	
	BeginSql Alias cAlsUs
	
		SELECT	CASE WHEN COUNT(*) > 0 THEN 'S' ELSE 'N' END TEMACESSO
		FROM 	%Table:Z03% Z03  	
		WHERE	Z03.%NotDel%
			AND Z03_GRUPO	= %Exp:cGrupo%
			AND Z03_CODUSR	= %Exp:cCodUsr%
				
	EndSql
	
	DbSelectArea(cAlsUs)
	
	lRet := (cAlsUs)->TEMACESSO = 'S'
	
	(cAlsUs)->(dbCloseArea())
	
	RestArea(aArea)
	
return lRet