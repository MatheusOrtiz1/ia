#include "rwmake.ch"
#include "topconn.ch"

//-------------------------------------------------------------------
/*/Desmarca FLAG de contabilização
@author Everton Forti
@since     	28/05/2015
@version 	1.0
/*/
//-------------------------------------------------------------------
User Function Desmarc()

cPerg := "DESMAR"
ValidPerg()
Pergunte(cPerg,.t.)

_dData := dDataBase

@ 96,42 TO 323,505 DIALOG oDlg1 TITLE "Desmarca Flag Contabil"
@ 8,10 TO 84,222
@ 23,14 SAY "Este programa desmarca os flags da contabilidade referentes a "     SIZE 200,08
@ 33,14 SAY "tabela escolhida nos parametros iniciais e contabilizar novamente."  SIZE 200,08  
//@ 65,14 SAY "Escolha a Data p/ Desmarcar :"
//@ 65,100 GET _dData SIZE 40,08
@ 91,168 BMPBUTTON TYPE 1 ACTION OkProc() 
@ 91,196 BMPBUTTON TYPE 2 ACTION Close(oDlg1)
ACTIVATE DIALOG oDlg1
Return nil

Static Function OkProc()
Processa({|| Desmar01()})
Return nil

Static Function Desmar01()

If mv_par01 == 1  // Desmarca tabela do Faturamento - SF2

    cQuery := " UPDATE "+ retsqlname("SF2")
    cQuery += " SET F2_DTLANC = ' ' "
    cQuery += " WHERE F2_FILIAL = '" + cFilAnt + "' AND "
	if mv_par14 == 1
		cQuery += " F2_TIPO = 'N' AND "
	elseif mv_par14 == 2	
		cQuery += " F2_TIPO = 'D' AND "
	endif
    cQuery += " F2_EMISSAO >= '" + DTOS(MV_PAR02) +"' AND F2_EMISSAO <= '"+DTOS(MV_PAR03)+"' AND "
    cQuery += " F2_DOC >= '" + MV_PAR04 +"' AND F2_DOC <= '"+MV_PAR05+"' AND "
    cQuery += " F2_CLIENTE >= '" + MV_PAR06 +"' AND F2_CLIENTE <= '"+MV_PAR07+"' AND "
    cQuery += " F2_LOJA >= '" + MV_PAR08 +"' AND F2_LOJA <= '"+MV_PAR09+"' AND "
    cQuery += " D_E_L_E_T_ = ' ' "

    TCSQLExec(cQuery)
    
	MsgBox("Desmarcada tabela de Notas de Saida com sucesso")

ElseIf mv_par01 == 2  // Desmarca tabela de Compras - SF1 
	// === Alterado F1_EMISSAO por F1_DTDIGIT, para considerar data da entrada de registro - 11/05/02 VSHiga

    cQuery := " UPDATE "+ retsqlname("SF1")
    cQuery += " SET F1_DTLANC = ' '"
    cQuery += " WHERE F1_FILIAL = '" + cFilAnt + "' AND "
	if mv_par14 == 1
		cQuery += " F1_TIPO = 'N' AND "
	elseif mv_par14 == 2	
		cQuery += " F1_TIPO = 'D' AND "
	endif
    cQuery += " F1_DTDIGIT >= '" + DTOS(MV_PAR02) +"' AND F1_DTDIGIT <= '"+DTOS(MV_PAR03)+"' AND "
    cQuery += " F1_DOC >= '" + MV_PAR04 +"' AND F1_DOC <= '"+MV_PAR05+"' AND "
    cQuery += " F1_FORNECE >= '" + MV_PAR10 +"' AND F1_FORNECE <= '"+MV_PAR11+"' AND "
    cQuery += " F1_LOJA >= '" + MV_PAR12 +"' AND F1_LOJA <= '"+MV_PAR13+"' AND "
    cQuery += " D_E_L_E_T_ = ' ' "

    TCSQLExec(cQuery)

	MsgBox("Desmarcada tabela de Notas de Entrada com sucesso")

ElseIf mv_par01 == 3  // Desmarca tabela de Contas a Receber - SE1 

    cQuery := " UPDATE "+ retsqlname("SE1")
    cQuery += " SET E1_LA = ' '"
    cQuery += " WHERE E1_FILIAL = '" + cFilAnt + "' AND "
    cQuery += " E1_EMISSAO >= '" + DTOS(MV_PAR02) +"' AND E1_EMISSAO <= '"+DTOS(MV_PAR03)+"' AND "
    cQuery += " E1_NUM >= '" + MV_PAR04 +"' AND E1_NUM <= '"+MV_PAR05+"' AND "
    cQuery += " E1_CLIENTE >= '" + MV_PAR06 +"' AND E1_CLIENTE <= '"+MV_PAR07+"' AND "
    cQuery += " E1_LOJA >= '" + MV_PAR08 +"' AND E1_LOJA <= '"+MV_PAR09+"' AND "
    cQuery += " SUBSTRING(E1_ORIGEM,1,4) = 'FINA' AND "
    cQuery += " D_E_L_E_T_ = ' ' "

    TCSQLExec(cQuery)

	MsgBox("Desmarcada tabela de Contas a Receber com sucesso")

ElseIf mv_par01 == 4  // Desmarca tabela de Contas a Pagar - SE2

    cQuery := " UPDATE "+ retsqlname("SE2")
    cQuery += " SET E2_LA = ' '"
    cQuery += " WHERE E2_FILIAL = '" + cFilAnt + "' AND "
    cQuery += " E2_EMIS1 >= '" + DTOS(MV_PAR02) +"' AND E2_EMIS1 <= '"+DTOS(MV_PAR03)+"' AND "
    cQuery += " E2_NUM >= '" + MV_PAR04 +"' AND E2_NUM <= '"+MV_PAR05+"' AND "
    cQuery += " E2_FORNECE >= '" + MV_PAR10 +"' AND E2_FORNECE <= '"+MV_PAR11+"' AND "
    cQuery += " E2_LOJA >= '" + MV_PAR12 +"' AND E2_LOJA <= '"+MV_PAR13+"' AND "
    cQuery += " SUBSTRING(E2_ORIGEM,1,4) = 'FINA' AND "
    cQuery += " D_E_L_E_T_ = ' ' "

    TCSQLExec(cQuery)

	MsgBox("Desmarcada tabela de Contas a Pagar com sucesso")

EndIf                                                          

If mv_par01 == 3 .OR. mv_par01 == 4  // Desmarca tabela de Caixa Bancos - SE5

    cQuery := " UPDATE "+ retsqlname("SE5")
    cQuery += " SET E5_LA = ' '"
    cQuery += " WHERE E5_FILIAL = '" + cFilAnt + "' AND "
    cQuery += " E5_DATA >= '" + DTOS(MV_PAR02) +"' AND E5_DATA <= '"+DTOS(MV_PAR03)+"' AND "
    cQuery += " E5_NUMERO >= '" + MV_PAR04 +"' AND E5_NUMERO <= '"+MV_PAR05+"' AND "
    cQuery += " E5_CLIFOR >= '" + MV_PAR10 +"' AND E5_CLIFOR <= '"+MV_PAR11+"' AND "
    cQuery += " E5_LOJA >= '" + MV_PAR12 +"' AND E5_LOJA <= '"+MV_PAR13+"' AND "
    cQuery += " E5_LA='S' AND "
    cQuery += " D_E_L_E_T_ = ' ' "

    TCSQLExec(cQuery)

	MsgBox("Desmarcada tabela de Movimento Caixa/Banco com sucesso")
ENDIF

Close(oDlg1)

Return .t.

Static Function ValidPerg()

Local _sAlias := Alias()
Local aRegs := {}
Local i,j

dbSelectArea("SX1")
dbSetOrder(1)
cPerg := PADR(cPerg,10) 


//Grupo/Ordem/Pergunta/PerSPA/PerENG/Variavel/Tipo/Tamanho/Decimal/Presel/GSC/Valid/Var01/Def01/DefSPA1/DefENG1/Cnt01/Var02/Def02/DefSPA2/DefENG2/Cnt02/Var03/Def03/DefSPA3/DefENG3/Cnt03/Var04/Def04/DefSPA4/DefENG4/Cnt04/Var05/Def05/DefSPA5/DefENG5/Cnt05/F3/GRPSXG
AADD(aRegs,{cPerg,"01","Quais Tabelas      ?","","","mv_ch1","N",1,0,1,"C","","mv_par01","Nota de Saida","","","","","Nota de Entrada","","","","","Contas a Receber","","","","","Contas a Pagar","","","","","","","","","","","","","",""})
AADD(aRegs,{cPerg,"02","Data De            ?","","","mv_ch2","D",8,0,1,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
AADD(aRegs,{cPerg,"03","Data Ate           ?","","","mv_ch3","D",8,0,1,"G","","mv_par03","","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
AADD(aRegs,{cPerg,"04","Nota De            ?","","","mv_ch4","C",9,0,1,"G","","mv_par04","","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
AADD(aRegs,{cPerg,"05","Nota Ate           ?","","","mv_ch5","C",9,0,1,"G","","mv_par05","","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
AADD(aRegs,{cPerg,"06","Cliente De         ?","","","mv_ch6","C",9,0,1,"G","","mv_par06","","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
AADD(aRegs,{cPerg,"07","Cliente Ate        ?","","","mv_ch7","C",9,0,1,"G","","mv_par07","","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
AADD(aRegs,{cPerg,"08","Loja Cliente De    ?","","","mv_ch8","C",3,0,1,"G","","mv_par08","","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
AADD(aRegs,{cPerg,"09","Loja Cliente Ate   ?","","","mv_ch9","C",3,0,1,"G","","mv_par09","","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
AADD(aRegs,{cPerg,"10","Fornecedor De      ?","","","mv_cha","C",9,0,1,"G","","mv_par10","","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
AADD(aRegs,{cPerg,"11","Fornecedor Ate     ?","","","mv_chb","C",9,0,1,"G","","mv_par11","","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
AADD(aRegs,{cPerg,"12","Loja Fornecedor De ?","","","mv_chc","C",3,0,1,"G","","mv_par12","","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
AADD(aRegs,{cPerg,"13","Loja Fornecedor Ate?","","","mv_chd","C",3,0,1,"G","","mv_par13","","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
AADD(aRegs,{cPerg,"14","Tipo de NF         ?","","","mv_che","C",1,0,1,"C","","mv_par14","Normal","","","","","Devolucao","","","","","Todos","","","","","","","","","","","","","","","","","","",""})

For i:=1 to Len(aRegs)
    If !dbSeek(cPerg+aRegs[i,2])
        RecLock("SX1",.T.)
        For j:=1 to FCount()
            If j <= Len(aRegs[i])
                FieldPut(j,aRegs[i,j])
            Endif
        Next
        MsUnlock()
    Endif
Next
dbSelectArea(_sAlias)

Return
