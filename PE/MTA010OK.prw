#include 'protheus.ch'
#include 'parmtype.ch'

/*/{Protheus.doc} MTA010OK
Na valida��o ap�s a confirma��o da exclus�o, antes de excluir o produto, ap�s verificar os saldos em estoque no arquivo referente (SB2). 
Deve ser utilizado para valida��es adicionais para a EXCLUS�O do Produto, para verificar algum arquivo/campo criado pelo usu�rio, 
para validar se o movimento ser� efetuado ou n�o.
@author ciro.chagas
@since 22/03/2017
@version undefined

@type function
/*/
user function MTA010OK()
	
	Local	lRet		:= .T.
	Local	cArea		:= GetArea()
	Local	lMovimento	:= StaticCall(M0000004, FS_MOVPROD, SB1->B1_COD)
	Local	cProdutoPai	:= SB1->B1_XPAI
	Local	cCodPai		:= SB1->B1_XCODPAI
	Local	lTemFilho	:= StaticCall(M0000004, FS_PROCFIL, cCodPai)
	
	If lRet
	
		//Valido se o produto j� teve movimento (mesmo deletado) na D1, D2 e D3
		If lMovimento
		
			MsgStop(u_Saudacao() + ", n�o � permitido a dele��o do produto, o mesmo j� houve movimenta��o no estoque.","MTA010OK - Produto com Movimento")
			lRet	:= .F.			
		
		EndIf
	
	EndIf
	
	If lRet
	
		If AllTrim(cProdutoPai) == "1"
		
			If lTemFilho
			
				MsgStop(u_Saudacao() + ", n�o � permitido a dele��o do produto, o mesmo � um produto Pai e possui produtos vinculados a ele.","MTA010OK - Produto Pai")
				
			EndIf
		
		EndIf
	
	EndIf
	
	RestArea(cArea)
return lRet