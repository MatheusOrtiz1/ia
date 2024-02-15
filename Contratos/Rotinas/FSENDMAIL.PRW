#INCLUDE "Protheus.ch"

//+-------+----------------+------------------------------------------------------------------------------------------------------------+
//| Autor | ADRIANO GUEDES  | Data :  02.02.2023                                                                         
//+-------+--------+-------+------------------------------------------------------------------------------------------------------------+
//| Empresa        |  CONASA                                                                                                  
//+----------------+--------------------------------------------------------------------------------------------------------------------+
//| Arquivo Fonte  | fSendMail.prw                                                                                                     
//+----------------+--------------------------------------------------------------------------------------------------------------------+
//| Funcao:        |Chamada para envio de emails                                                                                                                    
//+----------------+--------------------------------------------------------------------------------------------------------------------+
//|Parametros      |                                                                                                                    
//+----------------+--------------------------------------------------------------------------------------------------------------------+
//|Objetivo        |                                                                                                                    
//|                |                                                                                                                    
//|                |                                                                                                                    
//|                |                                                                                                                    
//+----------------+--------------------------------------------------------------------------------------------------------------------+
//+-------------------------------------------------------------------------------------------------------+
//| Rotina de Email  
//+-------------------------------------------------------------------------------------------------------+
User Function fSendMail(cMail, cCC, cAssunto , cBody, aAnexo )  ///Mensag, cSubject)

	Local cSMTPAddr   	:= 'smtp.conasa.com'//'smtp-mail.outlook.com' //AllTrim(GetMv("MV_RELSERV"))
	Local cPOPAddr	 	:= 'pop.conasa.com'//'mail.outlook.com'
	Local cSMTPPort   	:= 587 
	Local cPOPPort	 	:= 995
	Local cAccount    	:= AllTrim(GetMv("MV_RELACNT"))
	Local cPassword   	:= AllTrim(GetMv("MV_RELPSW")) 
	
	
	
	//Local cConta      	:= cMail
	//Local cFrom       	:= cAccount    
	//Local lConnect    	:= .f.
	//Local lEnviou     	:= .f.
	
	Local iL
	Local lRet        	:= .t.         
	Local oServer  		:= Nil
	Local oMessage 		:= Nil
	Local nErr     		:= 0 
	Local nSMTPTime 		:= 120   
	//Local xRet := nil

	DEFAULT cCC      := ""
	DEFAULT cAssunto := "Email sem assunto"
	DEFAULT cBody    := ""
	DEFAULT aAnexo   := {}


	If ! Empty(cSMTPAddr) .And. ! Empty(cAccount) .And. ! Empty(cMail)

		// Instancia um novo TMailManager
		oServer := tMailManager():New()    

		// Usa SSL na conexao
		oServer:setUseSSL(.F.)
		oServer:setUseTLS(.T.)          
		// Inicializa
		oServer:init(cPopAddr, cSMTPAddr, cAccount, cPassword, cPOPPort, cSMTPPort)
	
		// Define o Timeout SMTP
		if oServer:SetSMTPTimeout(nSMTPTime) != 0
			MsgAlert("fSendMail - [ERROR]Falla al definir timeout")
			Return .F.
		endif
		// Conecta ao servidor
		if ( nErr := oServer:smtpConnect() ) != 0 
			MsgAlert("fSendMail - [ERROR]Falha ao conectar o servidor: " + oServer:getErrorString(nErr))
			oServer:smtpDisconnect()
			return .F.
		endif                      
		// Realiza autenticacao no servidor
		if (nErr := oServer:smtpAuth(cAccount, cPassword)) != 0 
			MsgAlert("fSendMail - [ERROR]Falha ao autenticar: " + oServer:getErrorString(nErr))
			oServer:smtpDisconnect()
			return .F.
		endif

		// Cria uma nova mensagem (TMailMessage)
		oMessage := tMailMessage():new()
		oMessage:clear()
		oMessage:cFrom    := cAccount  
		oMessage:cTo      := cMail


		oMessage:cCC      := cCC   ///ALLTRIM( GetMV("MV_WFCUP3C","") ) //'amachado@close-upinternational.com.br;sonia.matos@close-upinternational.com.br'
		oMessage:cBCC     := ''              
		oMessage:cSubject := cAssunto
		oMessage:cBody    := cBody


		For iL:= 1 to Len (aAnexo )
            if ( oMessage:AttachFile(aAnexo[iL]) ) < 0 
               MsgAlert("fMailNf - [ERROR]Falha ao anexar o arquivo " + aAnexo[iL])
            EndIf
        Next iL   
		
		// Envia a mensagem
		if ( nErr := oMessage:send(oServer) ) != 0
			MsgAlert("fSendMail - [ERROR]Falha ao enviar: " + oServer:getErrorString(nErr))
			oServer:smtpDisconnect()
			return .F.
		endif
		
		// Disconecta do Servidor
		oServer:smtpDisconnect()
	EndIf
		
Return(lRet) 
