#include 'protheus.ch'
#include 'parmtype.ch'

#define Pula chr(13) + chr(10)

/*/{Protheus.doc} A010TOK
PE A010TOK - Fun��o de Valida��o para inclus�o ou altera��o do Produto.
EM QUE PONTO: No in�cio das valida��es ap�s a confirma��o da inclus�o ou altera��o, 
antes da grava��o do Produto; deve ser utilizado para valida��es adicionais para a INCLUS�O ou ALTERA��O do Produto.
@author ciro.chagas
@since 09/03/2017
@version undefined

@type function
/*/
user function A010TOK()
	
	Local	lRet		:= .T.
	Local	cArea		:= GetArea()
	Local	cSegun		:= M->B1_SEGUM
	Local	nSldB8		:= 0
	Local	cString		:= ""
	Local	lMovimento	:= StaticCall(M0000004, FS_MOVPROD, M->B1_COD)
	
	If lRet	
		//10-03-17-Ciro:  Valida��o Segunda Unidade de Medida
		If AllTrim(cSegun) <> "L" .and. AllTrim(cSegun) <> "KG"
		
			MsgAlert(u_Saudacao() + ", para Segunda Unidade de Medida, � permitido apenas L = Litro ou KG = Kilograma.","A010TOK - Segunda Unidade de Medida Inv�lida")
			lRet	:= .F.
		EndIf 
	EndIf
	
	If lRet
		//22-03-17-Ciro: Valida��o de produtos cujo s�o de Lote e possuem Saldo de Lote por�m tentam remover a rastreabilidade
		If ALTERA .and. AllTrim(Upper(SB1->B1_RASTRO)) = "L"
		
			nSldB8	:=	StaticCall(M0000004, FS_COSLDB8, nil, M->B1_COD) 
						
			If (nSldB8 > 0) .and. AllTrim(Upper(M->B1_RASTRO)) <> "L"
				
				MsgStop(u_Saudacao() + ", n�o � poss�vel retirar a rastreabilidade de Lote do produto, o mesmo possui saldo em lote.","A010TOK - Retirar rastreabilidade")
				lRet	:= .F.
				
			EndIf
		
		EndIf
			
	EndIf
	
	If lRet
		If ALTERA .and. lMovimento
			//Se for altera��o e o produto tiver sido movimentado (D1, D2, D3) e os campos abaixo forem alterados, n�o � permitido a altera��o
			If (M->B1_UM <> SB1->B1_UM) .or. (M->B1_TIPCONV <> SB1->B1_TIPCONV) .or. (M->B1_CONV <> SB1->B1_CONV)
				If M->B1_UM <> SB1->B1_UM
					cString	:= "- primeira unidade. " + Pula
				EndIf
				If M->B1_TIPCONV <> SB1->B1_TIPCONV
					cString	:= "- tipo de convers�o. " + Pula
				EndIf
				If M->B1_CONV <> SB1->B1_CONV
					cString	:= "- fator de convers�o. " + Pula
				EndIf
				
				MsgStop(u_Saudacao() + ", n�o � permitido a altera��o dos campos abaixo devido o produto ter sido movimentado: " + Pula + cString, "A010TOK - Produto com Movimento")
				lRet	:= .F.
			EndIf
		EndIf
	EndIf
	
	RestArea(cArea)
	
return lRet