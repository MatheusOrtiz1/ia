#include "PROTHEUS.CH"

/*
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณMT103IPC  บAutor  ณEverton            บ Data ณ  21/01/15   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณPONTO DE ENTRADA NO DOCUMENTO DE ENTRADA PARA LEVAR OS      บฑฑ
ฑฑบ          ณCAMPOS DO PEDIDO PARA A TELA DE NOTA DE ENTRADA             บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ CONASA                                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

User Function MT103IPC

Local _nItem := PARAMIXB[1]                                      
local nPosCampo1 := ascan(aHeader,{|x| rtrim(x[2])=="D1_CO"})
Local _nPosCod   := AsCan(aHeader,{|x|Alltrim(x[2])=="D1_COD"})
Local _nPosDes   := AsCan(aHeader,{|x|Alltrim(x[2])=="D1_UDESCR"})
Local _nPosObs	 := AsCan(aHeader,{|x|Alltrim(x[2])=="D1_OBS"})
Local _nPosGar	 := AsCan(aHeader,{|x|Alltrim(x[2])=="D1_UDIASGA"})
Local xEmp := SuperGetMV("MV_UFILMX",.F.,"")
xEmp1 := xEmp

IF _nPosObs <> 0
	aCols[len(aCols),_nPosObs] 	 := SC7->C7_OBS 
ENDIF

if nPosCampo1 <> 0
	aCols[len(aCols),nPosCampo1] := SC7->C7_CO
endif	
	
If _nPosCod > 0 .And. _nItem > 0
	aCols[_nItem,_nPosDes] := SB1->B1_DESC 	 
Endif


IF cNumemp $ xEmp1 //.AND. FunName() == "MATA103"
	if nPosCampo1 <> 0
		aCols[len(aCols),_nPosGar] 	 := SC7->C7_UDIASGA 
	endif	
ENDIF		

Return          
