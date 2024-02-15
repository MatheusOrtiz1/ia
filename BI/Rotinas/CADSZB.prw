#include "protheus.ch"
#include "rwmake.ch"
#include "topConn.ch"
#include "fwMBrowse.ch"
#include "fwMVCDef.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CADSZ9    º Autor ³ DANIEL GOUVEA      º Data ³  03/05/22   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Funcionarios PJ                                          º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP6 IDE                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function CADSZB

	Private cCadastro := "Funcionarios PJ"

	Private aRotina := { {"Pesquisar","AxPesqui",0,1} ,;
		{"Visualizar","AxVisual",0,2} ,;
		{"Incluir","AxInclui",0,3} ,;
		{"Alterar","AxAltera",0,4} ,;
		{"Ajuste Valor","U_AJUSZB",0,4} ,;
		{"Consulta Historico","U_CONSSZC",0,4} ,;
		{"Excluir","AxDeleta",0,5} }

	Private cDelFunc := ".T." // Validacao para a exclusao. Pode-se utilizar ExecBlock

	Private cString := "SZB"

	dbSelectArea("SZB")
	dbSetOrder(1)

	dbSelectArea(cString)
	mBrowse( 6,1,22,75,cString)

Return

User Function AJUSZB
	local _area := getarea()
	Local dNovoVenc := SZB->ZB_DTFIM
	Local nValor := SZB->ZB_SALARIO
	lOCAL cCNPJ := ALLTRIM(SZB->ZB_CGC)
	Local cGestor := SZB->ZB_RESPTEC
	Local cMotivo := space(30)
	Local dVencto := SZB->ZB_DTFIM
	Local nNovoVal := 0
	Local nOpc := 0

	DEFINE MSDIALOG oDlg TITLE "Alteração Valores" FROM 000, 000  TO 240, 500 COLORS 0, 16777215 PIXEL

	@ 010, 005 SAY oSay1 PROMPT "CPF/CNPJ:" SIZE 050, 007 OF oDlg COLORS 0, 16777215 PIXEL
	@ 025, 005 SAY oSay2 PROMPT "Gestor:" SIZE 166, 007 OF oDlg COLORS 0, 16777215 PIXEL
	@ 040, 005 SAY oSay3 PROMPT "Valor:" SIZE 025, 007 OF oDlg COLORS 0, 16777215 PIXEL
	@ 040, 125 SAY oSay5 PROMPT "Novo Valor:" SIZE 037, 007 OF oDlg COLORS 0, 16777215 PIXEL
	@ 055, 005 SAY oSay4 PROMPT "Data Vencto:" SIZE 037, 007 OF oDlg COLORS 0, 16777215 PIXEL
	@ 055, 125 SAY oSay6 PROMPT "Novo Vencto:" SIZE 037, 007 OF oDlg COLORS 0, 16777215 PIXEL
	@ 070, 005 SAY oSay7 PROMPT "Motivo:" SIZE 037, 007 OF oDlg COLORS 0, 16777215 PIXEL
	@ 010, 050 MSGET oGet1 VAR cCNPJ SIZE 080, 010 OF oDlg PICTURE IIF(LEN(cCNPJ)<14,'@R 999.999.999-99','@R 99.999.999/9999-99') COLORS 0, 16777215 WHEN .F. PIXEL
	@ 025, 050 MSGET oGet2 VAR cGestor SIZE 170, 010 OF oDlg COLORS 0, 16777215 WHEN .F. PIXEL
	@ 040, 050 MSGET oGet3 VAR nValor SIZE 060, 010 OF oDlg PICTURE '@E 99,999,999,999.99' COLORS 0, 16777215 WHEN .F. PIXEL
	@ 040, 160 MSGET oGet5 VAR nNovoVal SIZE 060, 010 OF oDlg PICTURE '@E 99,999,999,999.99' COLORS 0, 16777215 PIXEL
	@ 055, 050 MSGET oGet4 VAR dVencto SIZE 060, 010 OF oDlg COLORS 0, 16777215 when .f. PIXEL
	@ 055, 160 MSGET oGet6 VAR dNovoVenc SIZE 060, 010 OF oDlg COLORS 0, 16777215 PIXEL
	@ 070, 050 MSGET oGet7 VAR cMotivo SIZE 170, 010 OF oDlg PICTURE '@!' COLORS 0, 16777215 PIXEL
	@ 085, 141 BUTTON oButton1 PROMPT "OK" action (nOpc:=1,oDlg:end()) SIZE 033, 011 OF oDlg PIXEL
	@ 085, 182 BUTTON oButton2 PROMPT "Cancelar" ACTION oDlg:end() SIZE 033, 011 OF oDlg PIXEL

	ACTIVATE MSDIALOG oDlg

	if nOpc==1
		if empty(alltrim(cMotivo)) .or. len(alltrim(cMotivo))<5
			alert("Por favor informar um motivo.")
			return
		endif
		if nNovoVal<=0
			alert("Por favor informar um valor.")
			return
		endif
		dbselectarea("SZC")
		if reclock("SZC",.T.)
			ZC_FILIAL  := xFilial()
			ZC_DATAANT := dVencto
			ZC_DATADEP := dNovoVenc
			ZC_USUARIO := usrfullname(__cuserid)
			ZC_DATAALT := date()
			ZC_HORAALT := time()
			ZC_VALORAN := nValor
			ZC_VALORDE := nNovoVal
			ZC_MOTIVO  := cMotivo
			ZC_CGC     := SZB->ZB_CGC
			msunlock()
		endif
		dbselectarea("SZB")
		if reclock("SZB",.F.)
			SZB->ZB_SALARIO := nNovoVal
			SZB->ZB_DTFIM   := dNovoVenc
			msunlock()
		endif
	endif

	restarea(_area)
return

User Function CONSSZC
	Local _area := getarea()
	Local aLista := {}
	dbselectarea("SZC")
	dbsetorder(1)//ZC_FILIAL+ZC_CGC+DTOS(ZC_DATAALT)
	if dbseek(xFilial()+SZB->ZB_CGC)
		while !eof() .and. xFilial()+SZB->ZB_CGC==SZC->ZC_FILIAL+SZC->ZC_CGC
			aTmp := {}
			aadd(aTmp,SZC->ZC_USUARIO)
			aadd(aTmp,dtoc(SZC->ZC_DATAALT))
			aadd(aTmp,SZC->ZC_HORAALT)
			aadd(aTmp,dtoc(SZC->ZC_DATAANT))
			aadd(aTmp,dtoc(SZC->ZC_DATADEP))
			aadd(aTmp,transform(SZC->ZC_VALORAN,'@E 99,999,999,999.99'))
			aadd(aTmp,transform(SZC->ZC_VALORDE,'@E 99,999,999,999.99'))
			aadd(aTmp,SZC->ZC_MOTIVO )

			aadd(aLista,aTmp)
			dbselectarea("SZC")
			dbskip()
		enddo
	endif
	if len(aLista)>0
		DEFINE DIALOG oDlg TITLE "Historico Alterações" FROM 180,180 TO 580,940 PIXEL
		oBrowse := TCBrowse():New( 01 , 01, 380, 180,,;
			{'Usuario','Data Alt','Hora Alt','Data Fim Ant','Data Fim','Valor Ant','Valor','Motivo'},{50,30,30,30,30,50,50},;
			oDlg,,,,,{||},,,,,,,.F.,,.T.,,.F.,,, )

		oBrowse:SetArray(aLista)

		oBrowse:bLine := {||{ aLista[oBrowse:nAt,01],;
			aLista[oBrowse:nAt,02],;
			aLista[oBrowse:nAt,03],;
			aLista[oBrowse:nAt,04],;
			aLista[oBrowse:nAt,05],;
			aLista[oBrowse:nAt,06],;
			aLista[oBrowse:nAt,07],;
			aLista[oBrowse:nAt,08] } }
            
		@ 185, 020 BUTTON oButton1 PROMPT "Excel" action excel(aLista) SIZE 033, 011 OF oDlg PIXEL
		@ 185, 100 BUTTON oButton1 PROMPT "Fechar" action oDlg:end() SIZE 033, 011 OF oDlg PIXEL
		ACTIVATE DIALOG oDlg CENTERED
	endif
	restarea(_area)
return

static function excel(aLista)
	LOCAL I
	_planilha := "HISTORICO"
	_tab := "EMPRESA "+SUBSTR(cEmpAnt,1,2)
	oExcel := FWMSEXCELEX():New()
	oExcel:AddworkSheet(_planilha)
	oExcel:AddTable(_planilha,_tab)
	oExcel:AddColumn(_planilha,_tab,"CPF/CNPJ",1,1)
	oExcel:AddColumn(_planilha,_tab,"NOME",1,1)
	oExcel:AddColumn(_planilha,_tab,"RESPONSAVEL",1,1)
	oExcel:AddColumn(_planilha,_tab,"USUARIO ALTERAÇÃO",1,1)
	oExcel:AddColumn(_planilha,_tab,"DATA ALTERAÇÃO",1,1)
	oExcel:AddColumn(_planilha,_tab,"HORA ALTERAÇÃO",1,1)
	oExcel:AddColumn(_planilha,_tab,"DATA FIM ANT",1,1)
	oExcel:AddColumn(_planilha,_tab,"DATA FIM",1,1)
	oExcel:AddColumn(_planilha,_tab,"VALOR ANT",1,1)
	oExcel:AddColumn(_planilha,_tab,"VALOR",1,1)
	oExcel:AddColumn(_planilha,_tab,"MOTIVO",1,1)
	FOR I:=1 TO LEN(ALISTA)
		aAux := {}
		aadd(aAux,TRANSFORM(SZB->ZB_CGC,IIF(LEN(SZB->ZB_CGC)<14,'@R 999.999.999-99','@R 99.999.999/9999-99')))
		aadd(aAux,SZB->ZB_NOME)
		aadd(aAux,SZB->ZB_RESPTEC)
		aadd(aAux,aLista[i,1])
		aadd(aAux,aLista[i,2])
		aadd(aAux,aLista[i,3])
		aadd(aAux,aLista[i,4])
		aadd(aAux,aLista[i,5])
		aadd(aAux,aLista[i,6])
		aadd(aAux,aLista[i,7])
		aadd(aAux,aLista[i,8])
		oExcel:AddRow(_planilha,_tab,aAux)
	NEXT
	cNomeArq := "HISTORICO"+STRTRAN(TIME(),":","")+".xml"
	_temp := gettemppath()
	oExcel:Activate()
	oExcel:GetXMLFile(_temp+cNomeArq)
	oExcelApp := MsExcel():New()
	oExcelApp:WorkBooks:Open( _temp+cNomeArq )
	oExcelApp:SetVisible(.T.)
return
