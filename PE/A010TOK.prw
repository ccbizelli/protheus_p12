#include 'protheus.ch'
#include 'parmtype.ch'

#define Pula chr(13) + chr(10)

/*/{Protheus.doc} A010TOK
PE A010TOK - Função de Validação para inclusão ou alteração do Produto.
EM QUE PONTO: No início das validações após a confirmação da inclusão ou alteração, 
antes da gravação do Produto; deve ser utilizado para validações adicionais para a INCLUSÃO ou ALTERAÇÃO do Produto.
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
		//10-03-17-Ciro:  Validação Segunda Unidade de Medida
		If AllTrim(cSegun) <> "L" .and. AllTrim(cSegun) <> "KG"
		
			MsgAlert(u_Saudacao() + ", para Segunda Unidade de Medida, é permitido apenas L = Litro ou KG = Kilograma.","A010TOK - Segunda Unidade de Medida Inválida")
			lRet	:= .F.
		EndIf 
	EndIf
	
	If lRet
		//22-03-17-Ciro: Validação de produtos cujo são de Lote e possuem Saldo de Lote porém tentam remover a rastreabilidade
		If ALTERA .and. AllTrim(Upper(SB1->B1_RASTRO)) = "L"
		
			nSldB8	:=	StaticCall(M0000004, FS_COSLDB8, nil, M->B1_COD) 
						
			If (nSldB8 > 0) .and. AllTrim(Upper(M->B1_RASTRO)) <> "L"
				
				MsgStop(u_Saudacao() + ", não é possível retirar a rastreabilidade de Lote do produto, o mesmo possui saldo em lote.","A010TOK - Retirar rastreabilidade")
				lRet	:= .F.
				
			EndIf
		
		EndIf
			
	EndIf
	
	If lRet
		If ALTERA .and. lMovimento
			//Se for alteração e o produto tiver sido movimentado (D1, D2, D3) e os campos abaixo forem alterados, não é permitido a alteração
			If (M->B1_UM <> SB1->B1_UM) .or. (M->B1_TIPCONV <> SB1->B1_TIPCONV) .or. (M->B1_CONV <> SB1->B1_CONV)
				If M->B1_UM <> SB1->B1_UM
					cString	:= "- primeira unidade. " + Pula
				EndIf
				If M->B1_TIPCONV <> SB1->B1_TIPCONV
					cString	:= "- tipo de conversão. " + Pula
				EndIf
				If M->B1_CONV <> SB1->B1_CONV
					cString	:= "- fator de conversão. " + Pula
				EndIf
				
				MsgStop(u_Saudacao() + ", não é permitido a alteração dos campos abaixo devido o produto ter sido movimentado: " + Pula + cString, "A010TOK - Produto com Movimento")
				lRet	:= .F.
			EndIf
		EndIf
	EndIf
	
	RestArea(cArea)
	
return lRet