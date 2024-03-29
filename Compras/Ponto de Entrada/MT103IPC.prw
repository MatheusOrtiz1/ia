#include "PROTHEUS.CH"

/*
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
北赏屯屯屯屯脱屯屯屯屯屯送屯屯屯淹屯屯屯屯屯屯屯屯屯退屯屯屯淹屯屯屯屯屯屯槐�
北篜rograma  矼T103IPC  篈utor  矱verton            � Data �  21/01/15   罕�
北掏屯屯屯屯拓屯屯屯屯屯释屯屯屯贤屯屯屯屯屯屯屯屯屯褪屯屯屯贤屯屯屯屯屯屯贡�
北篋esc.     砅ONTO DE ENTRADA NO DOCUMENTO DE ENTRADA PARA LEVAR OS      罕�
北�          矯AMPOS DO PEDIDO PARA A TELA DE NOTA DE ENTRADA             罕�
北掏屯屯屯屯拓屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯贡�
北篣so       � CONASA                                                     罕�
北韧屯屯屯屯拖屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯屯急�
北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北�
哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌哌�
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
