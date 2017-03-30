#include 'protheus.ch'
#include 'parmtype.ch'

/*/{Protheus.doc} G0400006
Gatilho que valida a segunda unidade de medida no cadastro do Produto
@author ciro.chagas
@since 10/03/2017
@version undefined

@type function
/*/
user function G0400006()
	
	Local	cArea	:= GetArea()
	Local	cRet	:= M->B1_SEGUM
	
	If ! (AllTrim(M->B1_SEGUM) $ ("L/KG"))
	
		MsgAlert(u_Saudacao() + ", para Segunda Unidade de Medida, é permitido apenas L = Litro ou KG = Kilograma.","A010TOK - Segunda Unidade de Medida Inválida")
		cRet	:= ""
	
	EndIf
	
	RestArea(cArea)
return cRet