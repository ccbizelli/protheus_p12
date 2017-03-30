#include 'protheus.ch'
#include 'parmtype.ch'

/*/{Protheus.doc} G0400005
Gatilho para retornar a Descrição do Produto desde que o mesmo esteja associado a um código pai
@author ciro.chagas
@since 09/03/2017
@version undefined

@type function
/*/
user function G0400005()

	Local	cRet	:= ""
	Local	cArea	:= GetArea()
	Local	cDesc	:= IIf(M->B1_XPAI = "1",M->B1_XDSCRED,Posicione("SB1",12,M->B1_XCODPAI,"B1_XDSCRED"))
	Local	nConv	:= M->B1_CONV
	Local	cSegun	:= M->B1_SEGUM
	//Local	cDscUm	:= Posicione("SAH",1,FWxFilial("SAH")+M->B1_UM,"AH_DESCPO")
	//Local	cDscSeg	:= Posicione("SAH",1,FWxFilial("SAH")+cSegun,"AH_DESCPO")
	Local	nLitKg	:= 0
	Local	nMiliGr	:= 0
	
	IIf(nConv < 1,nMiliGr := nConv,nLitKg := nConv)
			
	//cRet	:= AllTrim(cDesc) + " - " + AllTrim(cDscUm) + " DE "
	cRet	:= AllTrim(cDesc) + " - " + AllTrim(M->B1_UM) + " DE "
	
	If ! Empty(nMiliGr)
		If cSegun = "L "
			cRet	+= cValToChar(round((nMiliGr) * 1000,2)) + " MILILITRO" + IIF(round((nMiliGr) * 1000,2) > 1,"S","")  
		ElseIf cSegun = "KG"
			cRet	+= cValToChar(round((nMiliGr) * 1000,2)) + " GRAMA" + IIF(round((nMiliGr) * 1000,2) > 1,"S","")
		EndIf
	ElseIf ! Empty(nLitKg)
		If cSegun = "L "
			cRet	+= cValToChar(nLitKg) + " LITRO" + IIF(nLitKg > 1,"S","")
		ElseIf cSegun = "KG"
			cRet	+= cValToChar(nLitKg) + " KILOGRAMA " + IIF(nLitKg > 1,"S","")
		EndIf		
	EndIf
	
	RestArea(cArea)
	
return Upper(Alltrim(cRet))