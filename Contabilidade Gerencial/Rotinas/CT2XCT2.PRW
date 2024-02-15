#INCLUDE "TOTVS.CH"
#include "protheus.ch"
#include "rwmake.ch"
#include "topConn.ch"
#include "fwMBrowse.ch"
#include "fwMVCDef.ch"
#INCLUDE "TBICONN.CH"
//Constantes
#Define STR_PULA    Chr(13)+Chr(10)
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºPrograma  CT2XCT2   º Autor ³ EVERTON FORTI     º Data ³  22/04/23     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ GERA CT2 DE COM LANÇAMENTOS DE OUTRA EMPRESA COM PERCENTUALº±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function CT2XCT2()
Private nValor   := 0.00

IF INPUT()
	PROCESSA({|| PROCCT2()})
ENDIF

Return()
///////////////////////////////////////////////
//PROCESSA
///////////////////////////////////////////////
Static Function PROCCT2()
Local CQUERY1 := ''
Local e
Local aArea  := GetArea()
Local aCab   := {}
Local aItens := {}
Local cCustoC := ""  
Local cCustoD := ""
Local cItemC := ""
Local cItemD := ""
Local cClvlD := ""
Local cClvlC := ""
Local cNewLote := ""
//MSExcel
Local aAux := {}
Local cSheet1 := "CT2"
Local cTab1 := "LANÇAMENTOS COPIADOS"
Local lOK := .T.
//Local cModo //Modo de acesso do arquivo aberto //"E" ou "C"
Local nLinha    := 0
Local _cEmpDest := MV_PAR01
Local _cFilDest := MV_PAR02
//Local dDatalc   := ""
//Local cNewAls := GetNextAlias() //Obtem novo Alias

Private lMsErroAuto := .F.
Private lMsHelpAuto := .T.
Private CTF_LOCK    := 0
Private lSubLote    := .T.

    Private aMail      := {}
	Private cFile		:= ""
	Private cMsg		:= ""
	Private cMenserro	:= ""
	Private cPass      := GETMV("MV_RELPSW")
	Private cAccount   := GETMV("MV_RELACNT")
	Private cServer    := GETMV("MV_RELSERV")
	Private cUsrMail   := GETMV("MV_RELACNT")
	Private csenha     := GETMV("MV_RELAPSW")
	Private cPara      :=  "everton.forti@totvs.com.br;diorgny@conasa.com;"
	Private cAssunto   	:= "CONASA - COPIA LANÇAMENTOS CONTABEIS "

    cPara += alltrim(usrretmail(__cUserID)) //Adiciona e-mail do usuário

    oExcel := FWMSEXCELEX():New()

    //SELECT TOP 1 CT2_LOTE FROM CT2Y30 CT2 WHERE CT2.D_E_L_E_T_='' AND CT2_LOTE >= '333333' AND CT2_LOTE <= '49999' 
    CQUERY2 := " SELECT  TOP 1 CT2_LOTE "
    CQUERY2 += " FROM "+RETSQLNAME("CT2")+" CT2 "
    CQUERY2 += " WHERE CT2.D_E_L_E_T_=''  AND CT2_DATA = '"+DTOS(ddatabase)+"'  "
    CQUERY2 += " AND CT2_LOTE >= '300000' AND CT2_LOTE <= '499999' "
    CQUERY2 += " ORDER BY CT2_LOTE DESC "

    IF SELECT("TRB3")!=0
        TRB3->(DBCLOSEAREA  ())
    ENDIF   
    CONOUT(CQUERY2)
    TCQUERY CQUERY2 NEW ALIAS "TRB3" 
    DBSELECTAREA("TRB3")
    DBGOTOP()

    IF EMPTY(TRB3->CT2_LOTE)
        cNewLote := "300000"
    ELSE
        cNewLote := TRB3->CT2_LOTE
        cNewLote := soma1(cNewLote)
    ENDIF

    aAdd(aCab, {'DDATALANC' ,dDataBase ,NIL} )
    aAdd(aCab, {'CLOTE'     ,cNewLote ,NIL} )
    aAdd(aCab, {'CSUBLOTE'  ,'001' ,NIL} )
    //aAdd(aCab, {'CDOC'      ,STRZERO( seconds() ,6) ,NIL} )
    aAdd(aCab, {'CPADRAO'   ,'' ,NIL} )
    aAdd(aCab, {'NTOTINF'   ,0 ,NIL} )
    aAdd(aCab, {'NTOTINFLOT',0 ,NIL} )


	CQUERY0 := " SELECT DISTINCT(CT2_DATA) AS CT2_DATA "
	CQUERY0 += " FROM "+alltrim("CT2"+_cEmpDest+"0")+ " CT2"
	CQUERY0 += " WHERE CT2.D_E_L_E_T_=''  "
	CQUERY0 += " AND CT2_FILIAL = '"+_cFilDest+"'  "
    CQUERY0 += " AND CT2_DATA >='"+DTOS(MV_PAR04)+"' AND CT2_DATA <='"+DTOS(MV_PAR05)+"' "

    IF SELECT("TRB0")!=0
		TRB0->(DBCLOSEAREA  ())
	ENDIF   
    CONOUT(CQUERY0)
	TCQUERY CQUERY0 NEW ALIAS "TRB0" 
	DBSELECTAREA("TRB0")
	DBGOTOP()

    WHILE TRB0->(!EOF())

        CQUERY1 := " SELECT * "
        cQuery1 += " FROM "+alltrim("CT2"+_cEmpDest+"0")+ " CT2"
        CQUERY1 += " WHERE CT2.D_E_L_E_T_=''  "
        CQUERY1 += " AND CT2_FILIAL = '"+_cFilDest+"' AND CT2_DATA = '"+TRB0->CT2_DATA+"'  "
        CQUERY1 += " ORDER BY CT2_DATA, CT2_LOTE, CT2_SBLOTE, CT2_DOC, CT2_LINHA "

        IF SELECT("TRB2")!=0
            TRB2->(DBCLOSEAREA  ())
        ENDIF   
        CONOUT(CQUERY1)
        TCQUERY CQUERY1 NEW ALIAS "TRB2" 
        DBSELECTAREA("TRB2")
        DBGOTOP()
        
        aItens := {}

            WHILE TRB2->(!EOF())

                //dDatalc := TRB2->CT2_DATA

                AADD(aMail,{TRB2->CT2_DATA, TRB2->CT2_LOTE , TRB2->CT2_SBLOTE , TRB2->CT2_DOC , TRB2->CT2_LINHA , TRB2->CT2_DC , TRB2->CT2_DEBITO , TRB2->CT2_CREDIT , (TRB2->CT2_VALOR*MV_PAR03)/100  ,;
                TRB2->CT2_HIST , TRB2->CT2_CCD , TRB2->CT2_CCC , TRB2->CT2_ITEMD  ,  TRB2->CT2_ITEMC  ,  TRB2->CT2_CLVLDB ,  TRB2->CT2_CLVLCR , TRB2->CT2_VALOR})
                
                //Centro de Custo
                IF EMPTY(TRB2->CT2_CCD)
                    cCustoD := ""
                else
                    cCustoD := MV_PAR06
                ENDIF
                IF EMPTY(TRB2->CT2_CCC)
                    cCustoC := ""
                else
                    cCustoC := MV_PAR06
                ENDIF

                //Item Contabil
                IF EMPTY(TRB2->CT2_ITEMD)
                    cItemD := ""
                else
                    cItemD := MV_PAR07
                ENDIF
                IF EMPTY(TRB2->CT2_ITEMC)
                    cItemC := ""
                else
                    cItemC := MV_PAR07
                ENDIF

                //Classe de Valor
                IF EMPTY(TRB2->CT2_CLVLDB)
                    cClvlD := ""
                else
                    cClvlD := MV_PAR08
                ENDIF
                IF EMPTY(TRB2->CT2_CLVLCR)
                    cClvlC := ""
                else
                    cClvlC := MV_PAR08
                ENDIF
                
                nLinha++
                CONOUT(CVALTOCHAR(nLinha))
                
                aAdd(aItens,  {;
                {'CT2_FILIAL' , xFilial('CT2')    , NIL},;
                {'CT2_LINHA'  , StrZero(nLinha,3) , NIL},;
                {'CT2_MOEDLC' , TRB2->CT2_MOEDLC  , NIL},;
                {'CT2_DC'     , TRB2->CT2_DC      , NIL},;
                {'CT2_DEBITO' , TRB2->CT2_DEBITO  , NIL},;
                {'CT2_CCD'    , cCustoD           , NIL},;
                {'CT2_ITEMD'  , cItemD            , NIL},;
                {'CT2_CLVLDB' , cClvlD            , NIL},;
                {'CT2_CREDIT' , TRB2->CT2_CREDIT  , NIL},;
                {'CT2_CCC'    , cCustoC           , NIL},;
                {'CT2_ITEMC'  , cItemC            , NIL},;
                {'CT2_CLVLCR' , cClvlC            , NIL},;
                {'CT2_VALOR'  , (TRB2->CT2_VALOR*MV_PAR03)/100   , NIL},;
                {'CT2_CONVER' ,'15555'            , NIL},;
                {'CT2_ORIGEM' , 'MSEXECAUT'       , NIL},;
                {'CT2_HP'     , ''                , NIL},;
                {'CT2_HIST'   , TRB2->CT2_HIST    , NIL} })

                TRB2->(DBSKIP())
            ENDDO


  
            IF LEN(aMail) == 0 
                MSGINFO( "Não foram encontrados para processamento", "ATENÇÃO" )
                return()
            ENDIF

          
            //IF EmpOpenFile("CT2","CT2",1,.T.,_cEmpDest,@cModo)//Abre tabela de outra empresa
                MSExecAuto({|x, y,z| CTBA102(x,y,z)}, aCab ,aItens, 3)

                nLinha    := 0
                
                If lMsErroAuto
                    MostraErro()
                    lMsErroAuto := .F.
                    lOK := .F.
                    LRETERRO := .F.
                    cErroMS := .T.
                EndIf

     TRB0->(DBSKIP())
     ENDDO

    
    
    //Monta Excel
    IF lOK
        oExcel:AddworkSheet(cSheet1)
		oExcel:AddTable(cSheet1,cTab1)
		oExcel:AddColumn(cSheet1,cTab1,"Data Lcto   ",1,1)
		oExcel:AddColumn(cSheet1,cTab1,"Numero Lote ",1,1)
		oExcel:AddColumn(cSheet1,cTab1,"Sub Lote    ",1,1)
		oExcel:AddColumn(cSheet1,cTab1,"Numero Doc  ",1,1)
		oExcel:AddColumn(cSheet1,cTab1,"Numero Linha",1,1)
		oExcel:AddColumn(cSheet1,cTab1,"Tipo Lcto   ",1,1)
		oExcel:AddColumn(cSheet1,cTab1,"Cta Debito  ",1,1)
		oExcel:AddColumn(cSheet1,cTab1,"Cta Credito ",1,1)
		oExcel:AddColumn(cSheet1,cTab1,"Valor       ",1,1)
		oExcel:AddColumn(cSheet1,cTab1,"Hist Lanc   ",1,1)
		oExcel:AddColumn(cSheet1,cTab1,"C Custo Deb ",1,1)
		oExcel:AddColumn(cSheet1,cTab1,"C Custo Cred",1,1)
		oExcel:AddColumn(cSheet1,cTab1,"Item Conta D",1,1)
		oExcel:AddColumn(cSheet1,cTab1,"Item Conta C",1,1)
		oExcel:AddColumn(cSheet1,cTab1,"Cl Vlr Deb  ",1,1)
		oExcel:AddColumn(cSheet1,cTab1,"Cl Vlr Cred ",1,1)
		oExcel:AddColumn(cSheet1,cTab1,"Percentual ",1,1)
		oExcel:AddColumn(cSheet1,cTab1,"Valor Orig.",1,1)


        for e := 1 to len(aMail)
            aAux := {}
            aadd(aAux,aMail[e][01])
            aadd(aAux,aMail[e][02])
            aadd(aAux,aMail[e][03])
            aadd(aAux,aMail[e][04])
            aadd(aAux,aMail[e][05])
            aadd(aAux,aMail[e][06])
            aadd(aAux,aMail[e][07])
            aadd(aAux,aMail[e][08])
            aadd(aAux,aMail[e][09])
            aadd(aAux,aMail[e][10])

            IF !EMPTY(aMail[e][11])
                aadd(aAux,MV_PAR06)
            else
                aadd(aAux,aMail[e][11])
            ENDIF

            IF !EMPTY(aMail[e][12])
                aadd(aAux,MV_PAR06)
            else
                aadd(aAux,aMail[e][12])
            ENDIF
            
            aadd(aAux,aMail[e][13])
            aadd(aAux,aMail[e][14])
            aadd(aAux,aMail[e][15])
            aadd(aAux,aMail[e][16])
            aadd(aAux,MV_PAR03)
            aadd(aAux,aMail[e][17])
        
            oExcel:AddRow(cSheet1,cTab1,aAux)

	    NEXT

        //GERA ARQUIVO XML PARA EXCEL
        cNomeArq := "COPIA_CT2_"+_cEmpDest+STRTRAN(TIME(),":","")+".xml"
        _temp := "\spool\"
        oExcel:Activate()
        oExcel:GetXMLFile(_temp+cNomeArq)
        cFile := "\spool\"+cNomeArq

             //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
            //³Efetua o envio do e-mail de aviso ao departamento de compras³
            //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
            If !EMPTY(cPara)
                CONNECT SMTP SERVER cServer ACCOUNT cAccount PASSWORD cPass Result lConectou
                If lConectou

                    MAILAUTH(cAccount, cPass)

                    SEND MAIL FROM ALLTRIM(cAccount) TO cPara SUBJECT cAssunto BODY cMsg Attachment cFile Result lConectou

                    If !lConectou

                        GET MAIL ERROR cSmtpError

                    Endif

                EndIf

                DISCONNECT SMTP SERVER
                ferase(cFile)
                ferase(_temp+cNomeArq)
            EndIf

            MSGINFO( "PROCESSO CONCLUIDO COM SUCESSO!", "ATENÇÃO" )

    ENDIF

 RestArea(aArea)

 Return()

Static Function Input()
Local aPergs   := {}
Local cTitle     := "Gera lançamentos contabies conforme pecentual!"
local aRet       := {}
local bOk        := {|| .t.}
local aButtons   := {}
local lCentered  := .t.
local nPosX      := nil
local nPosY      := nil
local oDlgWizard := nil
Local cProgram   := "CT2XCT2"
local cLoad      := allTrim(cProgram) + ".pbx"
local lCanSave   := .t.
local lUserSave  := .t.
local okPress    := .f.
 
aAdd(aPergs, {1, "Empresa Origem? "  ,       Space(02)      ,  "@!", "", "EMP"   ,     "", 80, .T.})
aAdd(aPergs, {1, "Filial Origem ? "  ,      Space(02)       ,  "@!", "", "",     "", 80, .T.})
aAdd(aPergs, {1, "Percentual"        ,      nValor          ,  "@E 999.99"    , "Positivo()", "", ".T.", 80,  .T.})
aAdd(aPergs, {1, "Data De "          ,      CTOD(SPACE(8))  ,  "@D", "", ""   ,     "", 80, .T.})
aAdd(aPergs, {1, "Data Até "         ,      CTOD(SPACE(8))  ,  "@D", "", ""   ,     "", 80, .T.})
aAdd(aPergs, {1, "Centro de Custo? " ,      Space(20)       ,  "@!", "", "CTT",     "", 80, .F.})
aAdd(aPergs, {1, "Item Contabil ? "  ,      Space(20)       ,  "@!", "", "CTD",     "", 80, .F.})
aAdd(aPergs, {1, "Classe de Valor ? ",      Space(20)       ,  "@!", "", "CTH",     "", 80, .F.})

	okPress := paramBox(aPergs ;		//Array: 	Array contendo as perguntas
	, cTitle ;		//Caracter:	Título da tela
	, aRet ;		//Array:	Array contendo as respostas
	, bOk ;			//Array:	Code block para validar o botão Ok
	, aButtons; 	//Array:	Array contendo definições dos botões opcionais, além dos botões de Ok e Cancel
	, lCentered ; 	//Lógico:	Indica se será centralizada a janela
	, nPosX ;		//Numérico:	Se não centralizar janela, coordenada X da janela
	, nPosY ;		//Numérico:	Se não centralizar janela, coordenada Y da janela
	, oDlgWizard ;	//Objeto: 	Objeto referente à janela ativaS
	, cLoad ;		//Caracter:	Nome arquivo para gravar respostas
	, lCanSave ; 	//Lógico:	Indica se pode salvar o arquivo com respostas
	, lUserSave)	//Lógico:	Indica se salva nome do usuario no arquivo

	if !okPress
		return(.F.)
	endIf

Return(.T.)

