#include 'protheus.ch'
#include 'parmtype.ch'

/*/{Protheus.doc} MTA010OK
Na validação após a confirmação da exclusão, antes de excluir o produto, após verificar os saldos em estoque no arquivo referente (SB2). 
Deve ser utilizado para validações adicionais para a EXCLUSÃO do Produto, para verificar algum arquivo/campo criado pelo usuário, 
para validar se o movimento será efetuado ou não.
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
	
		//Valido se o produto já teve movimento (mesmo deletado) na D1, D2 e D3
		If lMovimento
		
			MsgStop(u_Saudacao() + ", não é permitido a deleção do produto, o mesmo já houve movimentação no estoque.","MTA010OK - Produto com Movimento")
			lRet	:= .F.			
		
		EndIf
	
	EndIf
	
	If lRet
	
		If AllTrim(cProdutoPai) == "1"
		
			If lTemFilho
			
				MsgStop(u_Saudacao() + ", não é permitido a deleção do produto, o mesmo é um produto Pai e possui produtos vinculados a ele.","MTA010OK - Produto Pai")
				
			EndIf
		
		EndIf
	
	EndIf
	
	RestArea(cArea)
return lRet