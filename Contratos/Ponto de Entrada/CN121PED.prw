#include "TOTVS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "RWMAKE.CH"
#INCLUDE "TBICONN.CH"
 
User Function CN121PED()   
    
Local _aarea	:=getarea() 
Local _areaCNE 	:= CNE->(getarea())                                 
Local _par1 	:= PARAMIXB[1]
Local _par2 	:= PARAMIXB[2]
Local _posCONTR
Local _posREVIS
Local _posNUMER
Local _posMEDIC
Local _posITEM
Local _posPROD
Local _posoBS
Local _i
//Local oModel    := Nil

//CNE_PEDTIT ==1
if LEN(_par1) > 0 .AND. LEN(_par2) > 0 

	//oModel := FwModelActive()//Modelo do CNTA121 
	
	for _i:=01 to len(_Par2)

		_posCONTR := aScan(_par2[_i],{|x| x[1]=="C7_CONTRA"})	//  CNE_CONTRATO
		_posREVIS := aScan(_par2[_i],{|x| x[1]=="C7_CONTREV"})	//  CNE_REVISA
		_posNUMER := aScan(_par2[_i],{|x| x[1]=="C7_PLANILH"})	//  CNE_NUMERO
		_posMEDIC := aScan(_par2[_i],{|x| x[1]=="C7_MEDICAO"})	//  CNE_NUMED
		_posITEM  := aScan(_par2[_i],{|x| x[1]=="C7_ITEMED"})	//  CNE_ITEM
		_posOBS   := aScan(_par2[_i],{|x| x[1]=="C7_OBS"})	    //  CNE_OBS
		_posPROD  := aScan(_par2[_i],{|x| x[1]=="C7_PRODUTO"})  // CNE_PRODUTO

		if _posCONTR > 0
			dbSelectArea("CNE")
			dbSetOrder(1)//CNE_FILIAL+CNE_CONTRA+CNE_REVISA+CNE_NUMERO+CNE_NUMMED+CNE_ITEM                                                                                                 
			if dbSeek(xFilial("CNE") + _par2[_i][_posCONTR][2] + _par2[_i][_posREVIS][2] + _par2[_i][_posNUMER][2] + _par2[_i][_posMEDIC][2] +  _par2[_i][_posITEM][2])
			
				AADD(_par2[_i],{"C7_CO",CNE->CNE_UNATUR,NIL}) // ADICIONA CONTA ORÇAMENTARIA
				
				_par2[_i][_posoBS][2] := CNE->CNE_UOBS 		// ADICIONA OBSERVAÇÃO

			endif
		endif
	next

else	//CNE_PEDTIT ==2

	if len(_Par1) > 0 .and.  LEN(_par2) == 0
	
		_posCONTR := aScan(_par1,{|x| AllTrim(x[1])=="E2_MDCONTR"})	//  CNE_CONTRATO

		_posREVIS := aScan(_par1,{|x| AllTrim(x[1])=="E2_MDREVIS"})	//  CNE_REVISA
		_posNUMER := aScan(_par1,{|x| AllTrim(x[1])=="E2_MDPLANI"})	//  CNE_NUMERO
		_posMEDIC := aScan(_par1,{|x| AllTrim(x[1])=="E2_MEDNUME"})	//  CNE_NUMED
		_posITEM  := aScan(_par1,{|x| AllTrim(x[1])=="E2_MDPARCE"})	//  CNE_ITEM

		if _posCONTR > 0
			dbSelectArea("CNE")
			dbSetOrder(1)//CNE_FILIAL+CNE_CONTRA+CNE_REVISA+CNE_NUMERO+CNE_NUMMED+CNE_ITEM                                                                                                 
			if dbSeek(xFilial("CNE") + _par1[_posCONTR][2] + _par1[_posREVIS][2] + _par1[_posNUMER][2] + _par1[_posMEDIC][2] ,.T.)
			
				AADD(_par1,{"E2_CCUSTO",CNE->CNE_CC,NIL}) // ADICIONA CONTA ORÇAMENTARIA
				AADD(_par1,{"E2_CCD",CNE->CNE_CC,NIL}) // ADICIONA CONTA ORÇAMENTARIA
				AADD(_par1,{"E2_CO",CNE->CNE_UNATUR,NIL}) // ADICIONA CONTA ORÇAMENTARIA
				AADD(_par1,{"E2_NAT2",CNE->CNE_UNATUR,NIL}) // ADICIONA CONTA ORÇAMENTARIA
				AADD(_par1,{"E2_CLVL",CNE->CNE_CLVL,NIL}) // ADICIONA CONTA ORÇAMENTARIA
				AADD(_par1,{"E2_ITEMCTA",CNE->CNE_ITEMCT,NIL}) // ADICIONA CONTA ORÇAMENTARIA
				
			endif
		ENDIF
	ENDIF
ENDIF

restarea(_aarea)	
restarea(_areaCNE)	

return {_par1,_par2}
