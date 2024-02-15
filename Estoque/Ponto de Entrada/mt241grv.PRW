#include "TOTVS.CH"
#include "rwmake.ch"
//////////////////////////////////////////////////////////////////////////
///  Inclusao Integração Z10 Maximo - Everton Forti - 10/2018	       ///
//  Consumo de matreial - MOVIMENTO INTERNO              ///
//////////////////////////////////////////////////////////////////////////

user function mt241grv()

local area  := alias()
local ordem := indexord()
local regis := recno()
LOCAL xEmp	:= SuperGetMV("MV_UFILMX",.F.,"")
//LOCAL xInteg
PRIVATE cSaldob2

xEmp1 := xEmp 

IF cNumemp $ xEmp1
//tratar para quando estornar
//xInteg := SuperGetMv("MV_UD3BLQ")  //trava para habilitar/desabilitar trava de controle de TAG por movimento interno	                            
	IF !l241Auto //Inclusão manual
		dbselectarea("SD3")
		dbsetorder(2)
		dbseek(xfilial("SD3")+cdocumento,.t.) 
		
		
			DBSELECTAREA("SB2")
			DBSETORDER(1)
			IF DBSEEK(xFilial("SB2")+SD3->D3_COD+SD3->D3_LOCAL)
				cSaldob2:= SB2->B2_QATU
			ELSE
			CriaSB2(SD3->D3_COD,SD3->D3_LOCAL)
			cSaldob2:= SD3->D3_QUANT
			ENDIF		
			
		
			
			while SD3->(!eof()) .and. SD3->D3_FILIAL+SD3->D3_DOC == xfilial("SD3")+cdocumento
		//		Alert("GRAVA Z10 INVBAL")	                                            
				
							IF RecLock("Z10",.t.)
							Z10->Z10_FILIAL 	:= xFilial("Z10")
							Z10->Z10_INREG 	 	:= "SD3"
							Z10->Z10_DATA 		:= DATE()
							Z10->Z10_USUARI 	:=  RetCodUsr()
							Z10->Z10_HORA  		:= time()
							Z10->Z10_MOVIME		:= '3' //Inclusao
							Z10->Z10_B1COD 		:= SD3->D3_COD
							Z10->Z10_B1DESC		:= POSICIONE("SB1",1,xFILIAL("SB1")+SD3->D3_COD,"B1_DESC")
							Z10->Z10_B1UM  		:= SD3->D3_UM
							Z10->Z10_LOCAL      := SD3->D3_LOCAL
							Z10->Z10_NNRDES     := POSICIONE("NNR",1,xFilial("NNR")+SD3->D3_LOCAL,"NNR_ULOCAT")          //
							Z10->Z10_CUSTD      := SD3->D3_CUSTO1
							Z10->Z10_CUSMED     := SD3->D3_CUSTO1
							Z10->Z10_UPRC       := 0
							Z10->Z10_ORIGEM		:= "MATA241"
							Z10->Z10_DESTIN		:= "MXINVENTORY"
							MsUnlock()
							ENDIF
					if reclock("Z10",.T.)
						//GRAVA TABELA DE INTEGRAÇÃO MAXIMO
						Z10->Z10_FILIAL 	:= xFilial("Z10")
						Z10->Z10_INREG 	 	:= "SD3"
						Z10->Z10_DATA 		:= DATE()
						Z10->Z10_USUARI 	:=  RetCodUsr()
						Z10->Z10_HORA  		:= time()
						Z10->Z10_MOVIME		:= '4' //Inclusao
						Z10->Z10_B1COD 		:= SD3->D3_COD
						Z10->Z10_B2COD 		:= SD3->D3_COD
						Z10->Z10_B1DESC		:= POSICIONE("SB1",1,xFILIAL("SB1")+SD3->D3_COD,"B1_DESC")
						Z10->Z10_B1UM  		:= SD3->D3_UM
						Z10->Z10_D3QTD 		:= cSaldob2
						Z10->Z10_B2QATU 	:= cSaldob2
						Z10->Z10_D3DOC		:= SD3->D3_DOC
						Z10->Z10_NNRDES		:= POSICIONE("NNR",1,xFilial("NNR")+SD3->D3_LOCAL,"NNR_ULOCAT")
						Z10->Z10_ORIGEM		:= "MATA241"
						Z10->Z10_DESTIN		:= "MXINVBAL            "
						MsUnlock()
					endif
			
			SD3->(dbskip())
			enddo
	ENDIF
ENDIF
dbselectarea(area)
dbsetorder(ordem)
dbgoto(regis)

return(.t.)

User Function Z10CAD()

AXCADASTRO("Z10","Tabela Integração Maximo")

RETURN(.T.)

User Function Z11CAD()

AXCADASTRO("Z11","Atendimento x OS")

RETURN(.T.)
