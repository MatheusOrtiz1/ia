#INCLUDE "PROTHEUS.CH" 
#INCLUDE "RWMAKE.CH" 
#INCLUDE "TOPCONN.CH"

USER FUNCTION MT100TOK() 
PRIVATE lRet 			:= .T. 

// Restrição para validações não serem chamadas duas vezes ao utilizar o importador da ConexãoNF-e, 
	// mantendo a chamada apenas no final do processo, quando a variável l103Auto estiver .F.
    If !FwIsInCallStack('U_GATI001') .Or. IIf(Type('l103Auto') == 'U',.T.,!l103Auto)

		IF FUNNAME() == "MATA103" .OR. FUNNAME()=="MATA910" .OR. FUNNAME()=="MATA140"
			IF LEN(ALLTRIM(CNFISCAL)) <> 9 .AND. LEN(ALLTRIM(CNFISCAL)) <> 0
				CNFISCAL := STRZERO(VAL(CNFISCAL),9)
			ENDIF  
		ENDIF        

		IF FUNNAME() == "SPEDNFE"
			return (lRet)
		ELSE
			UMTTOK()
		ENDIF
	EndIF

	If lRet
        // Ponto de chamada ConexãoNF-e sempre como última instrução.
        lRet := U_GTPE005() 
    EndIf
	
return (lRet)

STATIC FUNCTION UMTTOK()

local blkdata		:= GETMV("MV_UBKCODT")
local dtdigit		:= dDATABASE						//data base utilisada no momento da inclusão
local dtfincom		:= GETMV("MV_UFINCOM")		 		//paramentro de ultimo dia do mês atual para lançamento no compras 
Local nNextMes 		:= Month(dtfincom)+1                //proximo mes da data final para lançamento no compras
//local dtfinemis		:= CTOD("25/"+StrZero(Month(dtfincom),2)+"/"+Substr(Str(Year(dtfincom)),4))    	//data de emissão final para lançamento no compras no mes atual
local dtinicom		:= CTOD("01/"+Iif(nNextMes==13,"01",StrZero(nNextMes,2))+"/"+Substr(Str(Iif(nNextMes==13,Year(dtfincom)+1,Year(dtfincom))),4)) 	//primeiro dia do mes seguinte para lançamento no compras
Local Tipo		    := cTipo //Tipo da nota fiscal
LOCAL NMAX
LOCAL xCOD 	   := ASCAN(AHEADER,{|X|ALLTRIM(X[2])=="D1_COD"})
LOCAL xFornec  := ASCAN(AHEADER,{|X|ALLTRIM(X[2])=="D1_FORNECE"})
LOCAL xQTD	   := ASCAN(AHEADER,{|X|ALLTRIM(X[2])=="D1_QUANT"})
LOCAL xStatus  := ASCAN(AHEADER,{|X|ALLTRIM(X[2])=="D1_USTATUS"})
LOCAL xDiasg   := ASCAN(AHEADER,{|X|ALLTRIM(X[2])=="D1_UDIASGA"})
LOCAL xIDGara  := ASCAN(AHEADER,{|X|ALLTRIM(X[2])=="D1_UIDGARA"})
LOCAL AAREA    := GETAREA()
LOCAL LRET     := PARAMIXB[1]
LOCAL xEmp1 := SuperGetMv("MV_UFILMX",.F.,"")
LOCAL _X
local codfor	:= ""
lMT100TOK := .F.

/*
/*±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³MT100TOK  ºAutor  ³ Everton   INTEGMAX    Data ³  26/08/20   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±*/


IF FunName() == "MATA103" 
	IF INCLUI .OR. l103Class
		codfor		:= ACOLS[01,xFornec]
		IF blkdata
			IF Tipo="N"
				
				IF codfor!="119274450"
					IF dtdigit>dtfincom .and. dtdigit<dtinicom    			//valida data base de lançamento
						Aviso(" AVISO - DATABASE PARA LANÇAMENTO INVALIDA ","O Lançamento de nota fiscal nesse periodo nao e permitido...!",{"OK"},1) 
						lRet :=.F. 
					//ELSE 
					//	IF dtemissao>dtfinemis .and. dtemissao<dtinicom  	//valida data de emissao da nota fiscal
					//		Aviso(" AVISO - DATA DE EMISSAO INVALIDA ","O lançamento de nota fical com essa data de emissao nao e permitido...!",{"OK"},1)
					//		lRet:=.F. 
					//	ELSE
					//		lRet:=.T.
					//	ENDIF
						//MSGALERT("OK") 
					ENDIF
				ELSE
					lRet := .T.
				ENDIF
			ENDIF
		ENDIF

		IF cNumemp $ xEmp1 



			FOR _X:=1 TO LEN(ACOLS) //FOR POR ITEM

				IF !aCols[_X,len(aHeader)+1]

					xProd 	:= ACOLS[_X,xCOD]
					nQtdd1  := ACOLS[_X,xQTD] 
					xStat	:= ACOLS[_X,xStatus]
					xIDGa  	:= ALLTRIM(ACOLS[_X,xIDGara])
					cDiasga:= ACOLS[_X,xDiasg] 	

					CQUERY := " SELECT  COUNT(*) AS Z23QTD "
					CQUERY += " FROM "+RetSqlName("Z23") + " Z23"
					CQUERY += " WHERE Z23_ID=' "+xIDGa+" ' AND Z23_NEWTAG ='' AND Z23_COD =' "+xProd+" ' "
					CQUERY += " AND Z23_DTRET = ''  AND Z23.D_E_L_E_T_ = ' ' 
					IF SELECT("WORK")!=0
						WORK->(DBCLOSEAREA())
					ENDIF
					TCQUERY CQUERY NEW ALIAS "WORK"
					DBSELECTAREA("WORK")
					DBGOTOP()
					NMAX := WORK->Z23QTD
					/*
					IF NMAX < nQtdd1
						MSGBOX("Qtd garantia: "+ALLTRIM(STR(NMAX))+" | Qtd Nota"+ ALLTRIM(STR(nQtdd1))+" !","ID GARANTIA: "+xProd+" - "+xIDGa,"INFO")
						LRET := .F.
					else
						MSGBOX("Qtd garantia: "+ALLTRIM(STR(NMAX))+" | Qtd Nota"+ ALLTRIM(STR(nQtdd1))+" !","ID GARANTIA: "+xProd+" - "+xIDGa,"INFO")
					ENDIF
					*/
				ENDIF

			NEXT _X
		ENDIF
	ENDIF
ENDIF

RESTAREA(AAREA)


return (lRet)
