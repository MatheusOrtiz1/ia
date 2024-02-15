/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºPrograma  ³INCPROD   ºAutor  ³EVERTON FORTI       º Data ³  10/10/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Incrementa o codigo do produto dentro da classificacao      º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
user function incprod()

Local retorno := ""
Local area := alias()
Local ordem := indexord()
Local registro := recno()
Local cCodAux := ""
LOCAL xEmp := SuperGetMV("MV_UFILMX",.F.,"")

xEmp1 := xEmp

IF cNumemp $ xEmp1 .And. !(Empty(M->B1_UTIPMAT) .And. Empty(M->B1_UCARAC1) .And. Empty(M->B1_UCARAC2))
	If !Empty(M->B1_UCARAC1) .And. !Empty(M->B1_UCARAC2) .And. !Empty(M->B1_UTIPMAT)
		cCodAux := M->B1_UTIPMAT+"."+M->B1_UCARAC1+"."+M->B1_UCARAC2+"-"
		dbselectarea("SB1")
		dbsetorder(1)
		dbseek(xfilial()+rtrim(cCodAux)+"999",.t.)
		dbskip(-1)
		if bof() .or. substr(SB1->B1_COD,1,13) <> rtrim(cCodAux)
			retorno := rtrim(cCodAux) + "001"
		else
			retorno := rtrim(cCodAux) + strzero(val(substr(SB1->B1_COD,14,3)) + 1,3)
		endif
	else
		retorno := CriaVar("B1_COD")
	ENDIF
		
ELSE
	dbselectarea("SB1")
	dbsetorder(1)
	dbseek(xfilial()+rtrim(M->B1_GRUPO)+"999999",.t.)
	dbskip(-1)
	if bof() .or. substr(SB1->B1_COD,1,4) <> rtrim(M->B1_GRUPO)
		retorno := rtrim(M->B1_GRUPO) + "000001"
	else
		retorno := rtrim(M->B1_GRUPO) + strzero(val(substr(SB1->B1_COD,5,6)) + 1,6)
	endif
ENDIF
dbselectarea(area)
dbsetorder(ordem)
dbgoto(registro)

Return(retorno)
