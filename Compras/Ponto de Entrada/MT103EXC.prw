#Include "TOTVS.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBSRV.CH"
#Include "rwmake.ch"
#Include "tbiconn.ch"
#INCLUDE "TOPCONN.CH"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºPrograma  ³MT103FIM  ºAutor  Everton Forti          Data ³  01/10/2018 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ PE EXECUTADO NO FINAL DA NF ENTRADA EXCLUSAO DE TAG VIA JOBº±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
*/

User Function MT103EXC()

Local xEmp1:= SuperGetMv("MV_UFILMX",.F.,"")
Local _aParametros:= {}
Local i 
Local cNfGar := 0
Local xD1sta := ""

//-----------------------------------------------------------------
//----ADICIONAD GFORTI INICIO
//------------------------------------------------------------------

Local lOk         := .T.
Local cContrato   := ""
Local BRW_REQCTL  := aScan( aHeader, { |x| AllTrim( x[2] ) == "D1_REQCTRL" } )

Local iL, cAuxFld

	if BRW_REQCTL > 0
		// ### Validando se existe Medição de Contrato Efetuado ###
		For iL := 1 to Len(aCols)
			if !Empty( cAuxFld := Alltrim( SubStr( aCols[iL, BRW_REQCTL],26, 10 )) )
				if !(cAuxFld $ cContrato)
					cContrato += cAuxFld + "," 
				Endif
			Endif   
		Next iL 

		if !Empty( cContrato )
			lOk := .F.
			MsgAlert("Não é possivel excluir este Doc.Entrada pois existem Médição Contrato Vinculado(s)" + CRLF +;
					Left( cContrato, Len( cContrato )-1) , "## MEDICAO CONTRATO ##" )
		Endif
	ENDIF

//FIM GFORTI
//-----------------------------------------------------------------------------------------

	IF cNumemp $ xEmp1 .and. lOk

		IF FunName() == "MATA103" .OR. FunName() == "MATA140"		

			DBSELECTAREA("Z12")
			DBSETORDER(4)
			IF DBSEEK(xFILIAL("Z12")+SF1->F1_FORNECE+SF1->F1_LOJA+SF1->F1_DOC+SF1->F1_SERIE) //_Prod,_For,_Loj,_Doc

			
				//Valida se estorno NF Garantia
				xD1sta  	:= ASCAN(AHEADER,{|X|X[2]=="D1_USTATUS"})
				FOR i=1 to len(ACOLS) .AND. xD1sta > 0
					cNfGar := ACOLS[I,xD1sta] 
				NEXT I

				aadd( _aParametros,{cNumemp,SF1->F1_FORNECE,SF1->F1_LOJA,SF1->F1_DOC,SF1->F1_SERIE,SF1->F1_EMISSAO,SF1->F1_VALBRUT,RetCodUsr(),cNfGar})

				StartJob("U_DELTAGZ12()",GetEnvServer(),.F.,_aParametros)
				//U_DELTAGZ12(_aParametros)//debug

 				MSGINFO("Suas TAGs já estão sendo EXCLUIDAS em segundo plano, assim que terminar você será avisado por e-mail!","MT103EXC")
			ENDIF
		ENDIF
	ENDIF

Return(lOk)

USER FUNCTION DELTAGZ12(paramixb)  
Local lRet := .T.
Private xPar00, xPar01, xPar02, xPar03, xPar04, xPar05, xPar06, xPar07 ,xPar08,xPar09
Private aOldTags	:= {}

 
 CONOUT("PROCESSO INICIADO")
 CONOUT(SUBSTR(paramixb[01,01],1,2))
 CONOUT(SUBSTR(paramixb[01,01],3,2))

 PREPARE ENVIRONMENT EMPRESA SUBSTR(paramixb[01,01],1,2)  FILIAL SUBSTR(paramixb[01,01],3,2) //DEBUG COMENTAR

	xPar00	   := paramixb[01,01] // Empresa     
	xPar01	   := paramixb[01,02] //Fornecedor       
	xPar02	   := paramixb[01,03] //Loja   
	xPar03	   := paramixb[01,04] //Documento        
	xPar04	   := paramixb[01,05] //Série    
	xPar05	   := paramixb[01,06] //Emissão        
	xPar06	   := paramixb[01,07] //Valor total   
	xPar07	   := paramixb[01,08] //codigousuario     
	xPar08	   := paramixb[01,09] //Status Garantia 
	xPar09	   := time()   

	//Exclui a TAG na Exclusão da NOTA de Entrada
	DBSELECTAREA("Z12")
	DBSETORDER(4)
	IF DBSEEK(xFILIAL("Z12")+xPar01+xPar02+xPar03+xPar04) //_Prod,_For,_Loj,_Doc
		WHILE !EOF() .AND. xFilial("Z12")+Z12->Z12_CODFOR+Z12->Z12_LOJA+Z12->Z12_DOC+Z12->Z12_SERIE == xFILIAL("Z12")+xPar01+xPar02+xPar03+xPar04

				RecLock("Z12", .F.)
				Z12->Z12_STATUS := 'E'
				Z12->Z12_DATA   := DATE()
				Z12->Z12_USUARI := "EXCLUI"
				Z12->Z12_BAIXA	:= 'E'
				Z12->Z12_IMP	:= 'E'
				Z12->Z12_HORA 	:= TIME()
			MsUnLock()

            //----------------------------------------------------------//
            //-------------Se for garatantia limpa o status-------------//
            //----------------------------------------------------------//	
                
            IF ALLTRIM(Z12->Z12_TAG5) $ "G/R"

                DBSELECTAREA("Z23")
                DBSETORDER(4)
                IF DBSEEK(xFilial("Z23")+Z12->Z12_TAG)
                    xIDGa :=  Z23->Z23_ID
					
					Aadd(aOldTags,{Z23->Z23_COD,Z23->Z23_OLDTAG,})

                    IF RECLOCK("Z23",.F.)
                        Z23->Z23_NEWTAG := ""
                        Z23->Z23_DTRET  := DATE()
                        Z23->Z23_DOC 	:= ""
                        Z23->Z23_SERIE  := ""
                        Z23->Z23_CLIFOR	:= ""
                        Z23->Z23_LOJA	:= ""										
                    ENDIF
                

					DBSELECTAREA("Z22")
					DBSETORDER(1)
					IF DBSEEK(xFilial("Z22")+xIDGa)
						IF Z22->Z22_STATUS <> "2"
							IF RECLOCK("Z22",.F.)
								Z22->Z22_STATUS := "2"
							ENDIF
						ENDIF
					ENDIF
				ENDIF
            ENDIF

			Z12->(DBSKIP())
		ENDDO
	
		Envmail(paramixb) //envia e-mail ao termino do processo para avisar usuarios

	ENDIF      

	/*
	IF LEN(aOldTags) > 0
		FOR J=1 TO LEN(aOldTags)	
			DBSELECTAREA("Z12")
			DBSETORDER(2)
			IF DBSEEK(xFILIAL("Z12")+aOldTags[j][01],aOldTags[j][02]) //Filial+Codigo+TAG
				IF RecLock("Z12", .F.)
					Z12->Z12_BAIXA  = "X"
					Z12->Z12_STATUS = "I"
				MsUnlock()
				ENDIF
			ENDIF
		NEXT J
	ENDIF
	*/
	DBSELECTAREA("Z10")
	DBSETORDER(5)
	IF DBSEEK(xFILIAL("Z10")+xPar01+xPar02+xPar03+xPar04) //_Prod,_For,_Loj,_Doc 
	

		WHILE !EOF() .AND. xFilial("Z10")+Z10->Z10_FORNEC+Z10->Z10_LOJA+Z10->Z10_DOC+Z10->Z10_SERIE==xFILIAL("Z12")+xPar01+xPar02+xPar03+xPar04

			RecLock("Z10", .F.)              
			IF  Z10->Z10_STATUS == "S"
				IF 	ALLTRIM(Z10->Z10_DESTIN) =="MXASSET"
					Z10->Z10_DESTIN := "MXDESCARTE"
					Z10->Z10_STATUS := ""
				ELSE         
					dbDelete()
				ENDIF	     			
			ENDIF
			MsUnLock()
		Z10->(DBSKIP())
		ENDDO
	ENDIF
	
RESET ENVIRONMENT	 //DEBUG COMENTAR

Return lRet                      

Static Function Envmail(_aParametros)

	Private MVTAGJOB  := SuperGetMV("MV_UJOBTAG",.F.,"")  
	Private cMsg
	Private cPass      := GETMV("MV_RELPSW")
	Private cAccount   := GETMV("MV_RELACNT")
	Private cServer    := GETMV("MV_RELSERV")
	Private cUsrMail   := GETMV("MV_RELACNT")
	Private csenha     := GETMV("MV_RELAPSW")
	Private cPara      := MVTAGJOB
	//Private cPara      := "everton.forti@totvs.com.br" //COMENTAR PARA DEBUR
	Private cAssunto   := 'TAG EXCLUIDAS COM SUCESSO  '+ ALLTRIM(SM0->M0_NOMECOM)+' - Filial: '+SM0->M0_FILIAL

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	//³Inicia montagem do html com os dados da proposta de cotação recebida\processada³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

	cMsg := ""
	cMsg := '<html>'
	cMsg += '<head>'
	cMsg += '<title>Etiquetas excluidas com Suesso</title>'
	cMsg += '<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">'
	cMsg := '<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01//EN" "http://www.w3.org/TR/html4/strict.dtd">'
	cMsg += '<html xmlns="http://www.w3.org/1999/xhtml">'+ CRLF
	cMsg += '<head>'+ CRLF
	cMsg += '<title> TAG excluída com Suesso</title>'+ CRLF
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
	cMsg += '  </tr>'    
	cMsg += '  <tr>'
	cMsg += '  <th width="674" scope="col"><div align="left">'+ALLTRIM(SM0->M0_NOMECOM)+' - Filial: '+SM0->M0_FILIAL+ '</div></th> '
	cMsg += '  </tr>
		cMsg += '  <tr>'
	cMsg += '  <th width="674" scope="col"><div align="left"> Etiquetas EXCLUIDAS com Suesso</div></th> '
	cMsg += '  </tr>	
		cMsg += '  <tr>'
	cMsg += '  <th width="674" scope="col"><div align="left">Empresa: ' + xPar00+ '</div></th>'
		cMsg += '  </tr>
		cMsg += '  <tr>'
	cMsg += '  <th width="674" scope="col"><div align="left">Documento: ' + xPar03+ '</div></th>'
		cMsg += '  </tr>
		cMsg += '  <tr>'
	cMsg += '  <th width="674" scope="col"><div align="left">Serie: ' + xPar04+ '</div></th>'
		cMsg += '  </tr>
		cMsg += '  <tr>'
	cMsg += '  <th width="674" scope="col"><div align="left">Fornecedor:  ' + xPar01+ '</div></th>'
	cMsg += '  </tr>'
		cMsg += '  <tr>'
	cMsg += '  <th width="674" scope="col"><div align="left">Loja: ' +xPar02 + '</div></th>'
	cMsg += '  </tr>'
		cMsg += '  <tr>'
	cMsg += '  <th width="674" scope="col"><div align="left">Emissão: ' + DTOC(xPar05)+ '</div></th>'
	cMsg += '  </tr>'
		cMsg += '  <tr>'
	cMsg += '  <th width="674" scope="col"><div align="left">Tempo Inicio: ' + xPar09+ '</div></th>'
	cMsg += '  </tr>'
		cMsg += '  <tr>'
	cMsg += '  <th width="674" scope="col"><div align="left">Tempo Fim: ' + Time() + '</div></th>'
	cMsg += '  </tr>'
	cMsg += '</body>'
	cMsg += '</html>'

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	//³Efetua o envio do e-mail de aviso ao departamento de compras³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	If !EMPTY(cPara)
		CONNECT SMTP SERVER cServer ACCOUNT cAccount PASSWORD cPass Result lConectou

		If lConectou


			MAILAUTH(cAccount, cPass)

			SEND MAIL FROM ALLTRIM(cAccount) TO cPara SUBJECT cAssunto BODY cMsg Result lConectou

			If !lConectou

				GET MAIL ERROR cSmtpError

			Endif

		EndIf

		DISCONNECT SMTP SERVER
	EndIf

Return .T.


