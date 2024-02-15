#INCLUDE "tbiconn.ch"
#include "rwmake.ch"
#Include "PROTHEUS.Ch"
#include "topconn.ch"

User Function MT241LOK()
Local lRet 		:= .T.
LOCAL xTrava
LOCAL xEmp	
Local n
Local _nPos 
Local MVUD3MTG := SUPERGETMV("MV_UD3MTG",.F.,"000000/000022/000098")


IF !l241Auto //Inclusão manual
	
	if __Cuserid $ MVUD3MTG
		lRet := .T.
	else
		xEmp		:= SuperGetMV("MV_UFILMX",.F.,"")	
		n 		:= ParamIxb[1]
		
		xEmp1 := xEmp
		
		IF cNumemp $ xEmp1
			
			xTrava := Iif(SUPERGetMV("MV_UD3BLQ")== "S",.T.,.F.)
			
			_nPos := Ascan( aHeader, {|x|  x[2] = "D3_COD"} )
			
			xInteg:= POSICIONE("SB1",1,xFilial("SB1")+ACOLS[1][_nPos ],"B1_UGERTAG")
			
			IF xInteg=="S"	//B1_UGERTAG = "S"
				IF  xTrava // MV_UD3BLQ = .T.
					ALERT("MV_UD3BLQ - Não é possivel Baixar material com TAG pela rotina de movimento Inetrno")
					lRet := .F.
				ENDIF
			ENDIF
			
			
			
		EndIf
	Endif
ENDIF

Return lRet
