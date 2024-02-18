/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³MT120ISC  ºAutor  ³Everton           º Data ³  21/01/15   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³PONTO DE ENTRADA NO PEDIDO DE COMPRAS                       º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ CONASA                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßtßßßßßßßßßßßßßßßßßßß
*/

USER FUNCTION MT120ISC()

LOCAL AAREA		:= GETAREA()
LOCAL NPOSCO    := ASCAN(AHEADER,{|X| ALLTRIM(X[2]) == "C7_CO"}) 
//LOCAL NPOSAPROV := ASCAN(AHEADER,{|X| ALLTRIM(X[2]) == "C7_APROV"})         						// Alteração feita por Diorgny
LOCAL NCCUSTO   := ASCAN(AHEADER,{|X| ALLTRIM(X[2]) == "C7_CC"})         						// Alteração feita por Diorgny
//LOCAL NPOSUPROJ := ASCAN(AHEADER,{|X| ALLTRIM(X[2]) == "C7_UPROJ"})

ACOLS[N][NPOSCO] := SC1->C1_CO
//ACOLS[N][NPOSUPROJ] := SC1->C1_UPROJ 
    

//ACOLS[N][NPOSAPROV] := POSICIONE("AK5",1,xFILIAL("AK5")+SC1->C1_CO,"AK5_UGRPAP")//INCLUIDO 07/06/2019


IF LEFT(cNumEmp,2)="07"																				// Alteração feita por Diorgny
//	ACOLS[N][NPOSAPROV] := IF(ALLTRIM(SC1->C1_CC)$"7.02.001.001/7.02.001.002","000002","000001")	// Alteração feita por Diorgny
	
	IF ExistTrigger(AHEADER[NCCUSTO][2])

  	    RunTrigger(2,NCCUSTO,nil,,'C7_CC')

		SYSREFRESH()
	ENDIF 
   
	IF ExistTrigger(AHEADER[NPOSCO][2])

  	    RunTrigger(2,NPOSCO,nil,,'C7_CO')

		SYSREFRESH()
	ENDIF   
	
ENDIF   

IF ExistTrigger(AHEADER[NCCUSTO][2])

     RunTrigger(2,NCCUSTO,nil,,'SC7->C7_CC')

	SYSREFRESH()
ENDIF 
   
IF ExistTrigger(AHEADER[NPOSCO][2])

    RunTrigger(2,NPOSCO,nil,,'SC7->C7_CO')

	SYSREFRESH()
ENDIF                                                                                               // Alteração feita por Diorgny

RESTAREA(AAREA)

RETURN(.T.)
