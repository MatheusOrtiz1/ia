
#INCLUDE "PROTHEUS.CH"

User Function CalcDat(dData1,cMeses)
Local lRet	:= .T.
Local ResuDat	:= ""

dData1 := STOD(dData1)
dData2 := Date()

ResuDat := DateDiffMonth(dData1,dData2)

If ResuDat > cMeses
	lRet:= .F.
	//Alert("Numero de meses calculado maior que o informado!")
Endif

Return lRet
