#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "totvs.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TBICONN.CH"
/*
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao: Programa para importar lan?amentos mensais da CONTABILIDADE บฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function IMPCT2CSV()

Private cPerg       := "IMPCT2CSV "
Private oLeTxt		:= ""
Private aDadosArq		:= {}

VALIDPERG()

@ 300,1 TO 480,480 DIALOG oLeTxt TITLE OemToAnsi("Leitura de Arquivo Texto")
@ 02,10 TO 070,200
@ 10,018 Say " Este programa ira ler o conteudo de um arquivo texto, conforme"
@ 18,018 Say " os parametros definidos pelo usuario, com os registros do arquivo"
@ 26,018 Say " importa็ใo de lan็amentos contabies em SCV com 16 posi็๕es (;) !"

@ 70,128 BMPBUTTON TYPE 01 ACTION OkLeTxt6()
@ 70,158 BMPBUTTON TYPE 02 ACTION Close(oLeTxt)

Activate Dialog oLeTxt Centered

RETURN

/*/
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Programa principal                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
/*/
Static Function OkLeTxt6
Private cTitulo1	:= "Selecione o arquivo"
Private cExtens		:= ""
Private	cFileOpen 	:= ""
Private nHdl    	:= fOpen(mv_par01,68)
Private cEOL    	:= "CHR(13)+CHR(10)"

cFileOpen := cGetFile(cExtens,cTitulo1,,,.F.)

If !File(cFileOpen)
	MsgAlert("Arquivo CSV: "+cFileOpen+" nใo localizado","IMPCT1CSV")
	Return
Endif
	
	Processa({|| RunCont() },"Processando o Arquivo...")

Return

/*/
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Programa Importa                                           บฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function RunCont
Local cBuffer 			:= ""
Private aDados			:= {}
Private aNEncontrados	:= {}
Private Linha

FT_FUSE(cFileOpen) //ABRIR
FT_FGOTOP() //PONTO NO TOPO

ProcRegua(FT_FLASTREC()) //QTOS REGISTROS LER

//1	         2	          3	            4	           5	           6	          7	            8	          9	            10              11      12       13      14      15      16
//DATA	Numero lote    Sub Lote	    Numero Doc 	     Numer liha  	tipo lcto      cta Debto	 Cta Credto	     Valor        Historico        CCD      CCC     ItemD   ItemC   ClvlD   ClvlC


While !FT_FEOF() //FACA ENQUANTO NAO FOR FIM DE ARQUIVO
	IncProc()
	
	If FT_FLastRec() == 1
		FT_FSkip()
	endif
	
	IncProc() // Capturar dados
	cBuffer := FT_FREADLN() //LENDO LINHA
	
	//Tratativa para retirar caracteres especiais
	cBuffer := STRTRAN(cBuffer,"๏","")
	cBuffer	:= STRTRAN(cBuffer,"ฟ","")
	cBuffer := STRTRAN(cBuffer,"ป","")
	cBuffer := STRTRAN(cBuffer,"?","")
	cBuffer := STRTRAN(cBuffer,"!","")
	cBuffer := STRTRAN(cBuffer,"^","")
	cBuffer := STRTRAN(cBuffer,"้","e")
	cBuffer := STRTRAN(cBuffer,"๕","o")
	cBuffer := STRTRAN(cBuffer,"ร","A")
	cBuffer := STRTRAN(cBuffer,"ฉ","o")
	cBuffer := STRTRAN(cBuffer,"ใ","a")
	cBuffer := STRTRAN(cBuffer,"ใ","a")
    cBuffer := UPPER(cBuffer)
	cMsg := "C๓digo: " + cBuffer
	//MsgInfo(cMsg)
	
	aDados:= StrTokArr2(cBuffer, ";",.T.)
	
    AADD(aDadosArq,{ aDados[01],  aDados[02], aDados[03] , aDados[04], aDados[05], aDados[06], aDados[07], aDados[08], aDados[09], aDados[10], aDados[11], aDados[12], aDados[13], aDados[14], aDados[15], aDados[16]})

    IF LEN(aDadosArq) >= 1 .and. LEN(aDadosArq) <= 1
        layout()
        IF MsgYesNo("DESEJA CONTINUAR COM A IMPORTAวรO?", "VALIDA LAYOUT")
            
        ELSE
            RETURN()
        ENDIF	
    ENDIF
	
		
	FT_FSKIP() //pr๓ximo registro no arquivo txt
EndDo

FT_FUSE() //fecha o arquivo txt

IF len(aDadosArq) > 0
    Processa({|| PROCIMP() },"Importando...") //GRAVA IMPORTAวรO NA TABELA Z15
    //Envmail()//ENVIA E-MAIL DE ERRO E FINAL
    MsgInfo("Processo finalizada")
ELSE
    MsgInfo("Arquivo vazio ou fora do layout de 16 posi็๕es!")
ENDIF

cFileOpen 	:= ""

RETURN

Static Function PROCIMP()

Local aArea    := GetArea()
Local aCab     := {}
Local aItens   := {}
Local nX       := 0
Local CQUERY1  := ""
Local cNewLote := "200000"

Private lMsErroAuto := .F.
Private lMsHelpAuto := .T.
Private CTF_LOCK    := 0
Private lSubLote    := .T.
  
    //SELECT TOP 1 CT2_LOTE FROM CT2Y30 CT2 WHERE CT2.D_E_L_E_T_='' AND CT2_LOTE >= '333333' AND CT2_LOTE <= '49999' 
    CQUERY1 := " SELECT  TOP 1 CT2_LOTE "
	CQUERY1 += " FROM "+RETSQLNAME("CT2")+" CT2 "
	CQUERY1 += " WHERE CT2.D_E_L_E_T_=''  AND CT2_DATA = '"+DTOS(ddatabase)+"'  "
	CQUERY1 += " AND CT2_LOTE >= '200000' AND CT2_LOTE <= '299999' "
    CQUERY1 += " ORDER BY CT2_LOTE DESC "

    IF SELECT("TRB3")!=0
		TRB3->(DBCLOSEAREA  ())
	ENDIF   
    CONOUT(CQUERY1)
	TCQUERY CQUERY1 NEW ALIAS "TRB3" 
	DBSELECTAREA("TRB3")
	DBGOTOP()

    IF EMPTY(TRB3->CT2_LOTE)
        cNewLote := "200000"
    ELSE
        cNewLote := TRB3->CT2_LOTE
        cNewLote := soma1(cNewLote)
    ENDIF

 
    aAdd(aCab, {'DDATALANC' ,STOD(aDadosArq[01][01])  ,NIL} )
    aAdd(aCab, {'CLOTE'     ,cNewLote   ,NIL} )
    aAdd(aCab, {'CSUBLOTE'  ,'001'      ,NIL} )
    aAdd(aCab, {'CPADRAO'   ,''         ,NIL} )
    aAdd(aCab, {'NTOTINF'   ,0          ,NIL} )
    aAdd(aCab, {'NTOTINFLOT',0          ,NIL} )
    
    //1	         2	          3	            4	           5	           6	          7	            8	          9	            10              11      12       13      14      15         16
    //DATA	Numero lote    Sub Lote	    Numero Doc 	     Numer liha  	tipo lcto      cta Debto	 Cta Credto	     Valor        Historico        CCD      CCC     ItemD   ItemC   ClvlD   ClvlC
 
    For nX := 1 To len(aDadosArq)
    	aDadosArq[nx][09]:=STRTRAN(aDadosArq[nx][09],',',".")//CONVERTE VIRGULA EM PONTO SE HOUVER
        aAdd(aItens,  {;
            {'CT2_FILIAL' , xFilial('CT2')                       , NIL},;
            {'CT2_LINHA'  , StrZero(nX,3)                        , NIL},;
            {'CT2_MOEDLC' ,'01'                                  , NIL},;
            {'CT2_DC'     , aDadosArq[nx][06]                    , NIL},;
            {'CT2_DEBITO' , aDadosArq[nx][07]                    , NIL},;
            {'CT2_CREDIT' , aDadosArq[nx][08]                    , NIL},;
            {'CT2_VALOR'  , VAL(aDadosArq[nx][09])               , NIL},;
            {'CT2_HIST'   , aDadosArq[nx][10]                    , NIL},;
            {'CT2_CCD'    , aDadosArq[nx][11]                    , NIL},;
            {'CT2_CCC'    , aDadosArq[nx][12]                    , NIL},;
            {'CT2_ITEMD'  , aDadosArq[nx][13]                    , NIL},;
            {'CT2_ITEMC'  , aDadosArq[nx][14]                    , NIL},;
            {'CT2_CLVLDB' , aDadosArq[nx][15]                    , NIL},;
            {'CT2_CLVLCR' , aDadosArq[nx][16]                    , NIL},;
            {'CT2_ORIGEM' , "IMPCT2CSV"                          , NIL},;
            {'CT2_HP'     , ''                                   , NIL},;
            {'CT2_CONVER' ,'15555'                               , NIL}})
    Next nX
  
    MSExecAuto({|x, y,z| CTBA102(x,y,z)}, aCab ,aItens, 3)
     
    If lMsErroAuto
        MostraErro()
        lMsErroAuto := .F.
    ELSE
	    Processa({|| Envlog() },"Gerando E-mail de LOG...") //GRAVA IMPORTAวรO NA TABELA Z15
	    MsgInfo("Importa็ใo Finaliz ada!","Importa็ใo Lan็amentos Contแbeis!")
        
    EndIf
 
 
    RestArea(aArea)
  
RETURN


//VALIDA PERGUNTA
STATIC FUNCTION VALIDPERG()
**************************
LOCAL _AREA := GETAREA()
LOCAL AREGS := {}
Local J,I

DBSELECTAREA("SX1")
DBSETORDER(1)
CPERG 	:= PADR(CPERG,10)

// GRUPO/ORDEM/PERGUNTA/VARIAVEL/TIPO/TAMANHO/DECIMAL/PRESEL/GSC/VALID/VAR01/DEF01/CNT01/VAR02/DEF02/CNT02/VAR03/DEF03/CNT03/VAR04/DEF04/CNT04/VAR05/DEF05/CNT05/X1_F3
AADD(AREGS,{CPERG,"01","Arquivo ?  "," ?"," ?","MV_CHA","C",60,0,0,"G","","MV_PAR01","","","","","","","","","","","","","","","","","","","","","","","","","","","","","DIR"})
FOR I:=1 TO LEN(AREGS)
	IF !DBSEEK(CPERG+AREGS[I,2])
		RECLOCK("SX1",.T.)
		FOR J:=1 TO FCOUNT()
			IF J <= LEN(AREGS[I])
				FIELDPUT(J,AREGS[I,J])
			ENDIF
		NEXT
		MSUNLOCK()
	ENDIF
NEXT
RESTAREA(_AREA)
RETURN


//-------------------------------------------
//ENVIA OS EMAIL NO FINAL DA ROTINA
//-------------------------------------------
Static Function Envlog()
Local x
	Private cFile		:= ""
	Private cMsg		:= ""
	Private cMenserro	:= ""
	Private cPass      := GETMV("MV_RELPSW")
	Private cAccount   := GETMV("MV_RELACNT")
	Private cServer    := GETMV("MV_RELSERV")
	Private cUsrMail   := GETMV("MV_RELACNT")
	Private csenha     := GETMV("MV_RELAPSW")
	Private cPara      :=  "everton.forti@totvs.com.br;diorgny@conasa.com;"
	Private cAssunto   	:= "CONASA - IMPORTAวรO LANวAMENTOS CONTABEIS " + SM0->M0_NOMECOM

    cPara += alltrim(usrretmail(__cUserID)) //Adiciona e-mail do usuแrio


	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
	//ณInicia montagem do html com os dados da proposta de cota็ใo recebida\processadaณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ

	cMsg := ""
	cMsg := '<html>'
	cMsg += '<head>'
	cMsg += '<title>'+cAssunto+'</title>'
	cMsg += '<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">'
	cMsg := '<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01//EN" "http://www.w3.org/TR/html4/strict.dtd">'
	cMsg += '<html xmlns="http://www.w3.org/1999/xhtml">'+ CRLF
	cMsg += '<head>'+ CRLF
	cMsg += '<title> '+cAssunto+'</title>'+ CRLF
	cMsg += '<style type="text/css">'
	cMsg += '<!--'
	cMsg += '.style8 {font-family: Verdana, Arial, Helvetica, sans-serif; font-size: 10px; }'
	cMsg += '.style13 {color: #0033FF; font-family: Verdana, Arial, Helvetica, sans-serif; font-size: 10px; }'
	cMsg += '-->'
	cMsg += '</style>'
	cMsg += '</head>'
	cMsg += ' '
	cMsg += '<body>'
	cMsg += '<hr align="left" width="826">'
	cMsg += '<table width="827" border="0">'
	cMsg += '<h5>Usuario '+__CUSERID +" - "+ UsrFullName(__CUSERID)+" - "+time()+' </h5>'

//1	         2	          3	            4	           5	           6	          7	            8	          9	            10              11      12       13      14      15      16
//DATA	Numero lote    Sub Lote	    Numero Doc 	     Numer liha  	tipo lcto      cta Debto	 Cta Credto	     Valor        Historico        CCD      CCC     ItemD   ItemC   ClvlD   ClvlC

	if Len(aDadosArq) >0
		cMsg += '<table width="827" border="1">'
		cMsg += '  <tr>'
		cMsg += '    <th width="174" scope="col"><div align="left">DATA</div></th>'
		cMsg += '    <th width="174" scope="col"><div align="left">LOTE </div></th>'
		cMsg += '    <th width="174" scope="col"><div align="left">SUB-LOTE </div></th>'
		cMsg += '    <th width="674" scope="col"><div align="left">NUM.DOC </div></th>'
		cMsg += '    <th width="374" scope="col"><div align="left">NUM.LINHA </div></th>'
		cMsg += '    <th width="674" scope="col"><div align="left">TIPO LCTO </div></th>'
		cMsg += '    <th width="174" scope="col"><div align="left">CTA DEBTO </div></th>'
		cMsg += '    <th width="174" scope="col"><div align="left">CTA CREDITO </div></th>'
		cMsg += '    <th width="174" scope="col"><div align="left">VALOR </div></th>'
		cMsg += '    <th width="174" scope="col"><div align="left">HISTORICO </div></th>'
		cMsg += '    <th width="174" scope="col"><div align="left">CC. DEBITO </div></th>'
		cMsg += '    <th width="674" scope="col"><div align="left">CC. CREDTIO </div></th>'
		cMsg += '    <th width="374" scope="col"><div align="left">ITEM DEBITO </div></th>'
		cMsg += '    <th width="674" scope="col"><div align="left">ITEM CREDITO </div></th>'
		cMsg += '    <th width="174" scope="col"><div align="left">CLVL DEBTIO </div></th>'
		cMsg += '    <th width="174" scope="col"><div align="left">CLVL CREDITO </div></th>'
		cMsg += '  </tr>'
		for x := 1 to len(aDadosArq)
			cMsg += '  <tr>'
			cMsg += '    <td width="174" scope="col"><div align="left">' + DTOC(stod(aDadosArq[x][01]))+'</div></td>'
			cMsg += '    <td width="174" scope="col"><div align="left">' + aDadosArq[x][02]   + '</div></td>'
			cMsg += '    <td width="174" scope="col"><div align="left">' + aDadosArq[x][03]   + '</div></td>'
			cMsg += '    <td width="674" scope="col"><div align="left">' + aDadosArq[x][04]  + '</div></td>'
			cMsg += '    <td width="374" scope="col"><div align="left">' + aDadosArq[x][05]  + '</div></td>'
			cMsg += '    <td width="674" scope="col"><div align="left">' + aDadosArq[x][06]+ '</div></td>'
			cMsg += '    <td width="174" scope="col"><div align="left">' + aDadosArq[x][07]  + '</div></td>'
			cMsg += '    <td width="174" scope="col"><div align="left">' + aDadosArq[x][08]  + '</div></td>'
			cMsg += '    <td width="174" scope="col"><div align="left">' + Transform(val(aDadosArq[x][09]),"@E 999,999,999,999.99")+'</div></td>'
			cMsg += '    <td width="174" scope="col"><div align="left">' + aDadosArq[x][10]   + '</div></td>'
			cMsg += '    <td width="174" scope="col"><div align="left">' + aDadosArq[x][11]   + '</div></td>'
			cMsg += '    <td width="674" scope="col"><div align="left">' + aDadosArq[x][12]  + '</div></td>'
			cMsg += '    <td width="374" scope="col"><div align="left">' + aDadosArq[x][13]  + '</div></td>'
//			cMsg += '    <td width="674" scope="col"><div align="left">' + POSICIONE("SB1",1,XFILIAL("SB1")+aDadosArq[x][05]  ,"SB1->B1_DESC")  + '</div></td>'
			cMsg += '    <td width="174" scope="col"><div align="left">' + aDadosArq[x][14]  + '</div></td>'
			cMsg += '    <td width="174" scope="col"><div align="left">' + aDadosArq[x][15]  + '</div></td>'
			cMsg += '    <td width="174" scope="col"><div align="left">' + aDadosArq[x][16]  + '</div></td>'
			cMsg += '  </tr>'
		next
	ELSE
		cMsg += '<h5>Arquivo de LOG VAZIO.... </h5>'
	ENDIF
	cMsg += '  <tr>'
	cMsg += '        </table>'
	cMsg += '        </div>'
	cMsg += '   </tr>'
	cMsg += '   <tr>'
	cMsg += '   </tr>'
	cMsg += '<p>&nbsp;</p>'
	cMsg += '</body>'
	cMsg += '</html>'
	//(MATA250, D3OP, D3TM, D3COD, D3UM, D3LOCAL,D3DOC, D3QUANT, SALDO, DVALID)
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
	//ณEfetua o envio do e-mail de aviso ao departamento de comprasณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
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
	EndIf

Return .T.


//--------------------------------------------------------------
/*/{Protheus.doc} MyFunction
Description                                                     
                                                                
@param xParam Parameter Description                             
@return xRet Return Description                                 
@author Everton Forti - everton.forti@totvs.com.br                                              
@since 27/01/2023                                                   
/*/
//--------------------------------------------------------------
Static Function layout()                        
Local oButton1
Local oGet1
Local cGet1 :=  aDados[01]
Local oGet2
Local cGet2 :=  aDados[02]
Local oGet3
Local cGet3 :=  aDados[03]
Local oGet4
Local cGet4 :=  aDados[04]
Local oGet5
Local cGet5 :=  aDados[05]
Local oGet6
Local cGet6 :=  aDados[06]
Local oGet7
Local cGet7 :=  aDados[07]
Local oGet8
Local cGet8 :=  aDados[08]
Local oGet9
Local cGet9 :=  aDados[09]
Local oGet10
Local cGet10 :=  aDados[10]
Local oSay1
Local oSay2
Local oSay3
Local oSay4
Local oSay5
Local oSay6
Local oSay7
Local oSay8
Local oSay9
Static oDlg

//AADD(aDadosArq,{ aDados[01],  aDados[02], CTOD(aDados[03]), aDados[04], aDados[05], aDados[06], aDados[07], aDados[08], aDados[09], aDados[10]})

  DEFINE MSDIALOG oDlg TITLE "VALIDA LAYOOUT IMPORTAวรO CSV" FROM 000, 000  TO 600, 600 COLORS 0, 16777215 PIXEL

    @ 020, 034 MSGET oGet1 VAR cGet1 SIZE 201, 010 OF oDlg COLORS 0, 16777215 READONLY PIXEL
    @ 045, 035 MSGET oGet2 VAR cGet2 SIZE 201, 010 OF oDlg COLORS 0, 16777215 READONLY PIXEL
    @ 070, 034 MSGET oGet3 VAR cGet3 SIZE 201, 010 OF oDlg COLORS 0, 16777215 READONLY PIXEL
    @ 095, 035 MSGET oGet4 VAR cGet4 SIZE 201, 010 OF oDlg COLORS 0, 16777215 READONLY PIXEL
    @ 120, 035 MSGET oGet5 VAR cGet5 SIZE 201, 010 OF oDlg COLORS 0, 16777215 READONLY PIXEL
    @ 150, 035 MSGET oGet6 VAR cGet6 SIZE 201, 010 OF oDlg COLORS 0, 16777215 READONLY PIXEL
    @ 175, 035 MSGET oGet7 VAR cGet7 SIZE 201, 010 OF oDlg COLORS 0, 16777215 READONLY PIXEL
    @ 201, 035 MSGET oGet8 VAR cGet8 SIZE 201, 010 OF oDlg COLORS 0, 16777215 READONLY PIXEL
    @ 224, 035 MSGET oGet9 VAR cGet9 SIZE 201, 010 OF oDlg COLORS 0, 16777215 READONLY PIXEL
    @ 250, 035 MSGET oGet10 VAR cGet10 SIZE 201, 010 OF oDlg COLORS 0, 16777215 READONLY PIXEL

//1	         2	          3	            4	           5	           6	          7	            8	          9	            10              11      12       13      14      15      16
//DATA	Numero lote    Sub Lote	    Numero Doc 	     Numer liha  	tipo lcto      cta Debto	 Cta Credto	     Valor        Historico        CCD      CCC     ItemD   ItemC   ClvlD   ClvlC


    @ 011, 034 SAY oSay1 PROMPT "DATA" SIZE 025, 007 OF oDlg COLORS 0, 16777215 PIXEL
    @ 034, 036 SAY oSay2 PROMPT "Numero lote" SIZE 055, 007 OF oDlg COLORS 0, 16777215 PIXEL
    @ 059, 034 SAY oSay3 PROMPT "Sub Lote" SIZE 073, 007 OF oDlg COLORS 0, 16777215 PIXEL
    @ 083, 035 SAY oSay4 PROMPT "Numero Doc" SIZE 054, 007 OF oDlg COLORS 0, 16777215 PIXEL
    @ 110, 036 SAY oSay5 PROMPT "Numer linha" SIZE 067, 007 OF oDlg COLORS 0, 16777215 PIXEL
    @ 136, 037 SAY oSay7 PROMPT "Tipo lcto" SIZE 060, 007 OF oDlg COLORS 0, 16777215 PIXEL
    @ 165, 036 SAY oSay6 PROMPT "Cta Debto" SIZE 067, 007 OF oDlg COLORS 0, 16777215 PIXEL
    @ 190, 039 SAY oSay8 PROMPT "Cta Credto" SIZE 097, 007 OF oDlg COLORS 0, 16777215 PIXEL
    @ 214, 036 SAY oSay9 PROMPT "Valor" SIZE 082, 007 OF oDlg COLORS 0, 16777215 PIXEL
    @ 240, 038 SAY oSay10 PROMPT "Historico" SIZE 025, 007 OF oDlg COLORS 0, 16777215 PIXEL

    @ 280, 236 BUTTON oButton1 PROMPT "FECHAR" SIZE 050, 012 OF oDlg PIXEL  ACTION oDlg:END()
	
  ACTIVATE MSDIALOG oDlg CENTERED

Return
