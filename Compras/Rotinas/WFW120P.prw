#include "PROTHEUS.CH"  
#include "TBICONN.CH" 
#include "rwmake.ch" 
#include "TbiCode.ch"
#include "ap5mail.ch"
#define ENTER CHR(13)+CHR(10)

/*
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Ponto de Entrada para uso em processo de WORKFLOW -         º±±
±±º          ³ Rotina de Liberação de Pedido de Compras                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
*/
USER function WFW120P( nOpcao, oProcess )
Local lAtiva := SuperGetMV("MV_UWF120P",.F.,.F.) //Parametro para ativar Workflow do compras
Private cPedido  :=  PARAMIXB	

IF !lAtiva
	RETURN()
ENDIF

If ValType(nOpcao) = "A"
	nOpcao := nOpcao[1]
Endif

If nOpcao == NIL
	nOpcao := 0
End
ConOut("Opcao:")
conout(nOpcao)

Do Case
	Case nOpcao == 0
		U_wFIniciar( oProcess ) //INICIA PROCESSO
	Case nOpcao == 1
		U_WFCOMRET( oProcess ) // RETORNO 
	Case nOpcao == 2
		U_WFCOMOUT( oProcess ) //TIMEOUT
endcase

RETURN

//-------------------------------------------------------------------
//wFiniciar - Função para envio do Workflow
//-------------------------------------------------------------------  
User Function WFIniciar( oProcess )
	//Local oProcess 	:= Nil							//Objeto da classe TWFProcess.
	Local cMailId 	:= ""							//ID do processo gerado. 
	//Local cHostWF	:= "http://192.168.0.60:8089"	//URL configurado no ini para WF Link. 
	Local cHostWFB	:= "http://protheus.conasa.com:8089"	//URL configurado no ini para WF Link. 
	Local cTo 		:= ""//"everton.forti@totvs.com.br;" 	//Destinatário de email.    
	Local xChavSCR
	Local nTotal	:= 0 
	Local cObs		:= ""
	Local lDEBUG	:= .F.
	Local cDest		:= ""	
	Local cAssunto  := "Workflo Pedido de Compras"	

	//IF lDEBUG
	//cPedido := "01000124"
	//PREPARE ENVIRONMENT EMPRESA "43" FILIAL "01"    
	//ENDIF

	//-------------------------------------------------------------------
	// "FORMULARIO"
	//-------------------------------------------------------------------  	
	
	dBselectArea('SC7')//PEDIDO COMPRA
	dbSetOrder(1)
	dbSeek(cPedido)
	//000754                                            '
	xChavSCR:= xFilial("SCR")+"PC"+SC7->C7_NUM+SPACE(44)+"01"
	
	dBselectArea('SCR')
	dbSetOrder(1)
	if dbSeek(xChavSCR)
		CONOUT("Encontrou SCR")	
		WHILE SCR->(!EOF()) .AND. SCR->CR_FILIAL+SCR->CR_TIPO+SCR->CR_NUM+SCR->CR_NIVEL == xChavSCR
			cTo += UsrRetMail(SCR->CR_USER)+";"
			cDest += UsrRetMail(SCR->CR_USER)+";"
		SCR->(DBSKIP())
		ENDDO
	else
		CONOUT("Não encontrou SCR")	
		Return()
	endif

	dBselectArea('SCR')//ALCADAS PED.COMRA
	dbSetOrder(1)
	dbSeek(xChavSCR)
                      
	dBselectArea('SA2')//FORNECEDORES
	dbSetOrder(1)
	dbSeek(xFilial("SA2")+SC7->C7_FORNECE)
	
	dbSelectArea('SE4')//COND.PAGAMENTO
	dbSetOrder(1)
	dbSeek(xFilial('SE4')+SC7->C7_COND)
	
	dbSelectArea('SAK')//APROVADORES
	dbSetOrder(1)
	dbSeek(xFilial('SAK')+SCR->CR_APROV)

	cAssunto  := "Workflow Compras "+Alltrim(SM0->M0_NOME) + " - "+ alltrim(SM0->M0_FILIAL) +" - Pedido:  "+Substr(cPedido,3,6)+"-"+SA2->A2_NREDUZ

	//-------------------------------------------------------------------
	// Instanciamos a classe TWFProcess informando o código e nome do processo.  
	//-------------------------------------------------------------------  
	oProcess := TWFProcess():New("000001", cAssunto)

	//-------------------------------------------------------------------
	// Criamos a tafefa principal que será respondida pelo usuário.  
	//-------------------------------------------------------------------  
	oProcess:NewTask("FORMULARIO", "\Workflow\WF_FORMCOM.html")

	//-------------------------------------------------------------------
	// Atribuímos valor a um dos campos do formulário.  
	//-------------------------------------------------------------------  	   
	oProcess:oHtml:ValByName("TEXT_TIME"	, Time() )
	oProcess:oHtml:ValByName("EMPRESA"		, SM0->M0_NOMECOM )
	oProcess:oHtml:ValByName("PEDIDO"		, SC7->C7_NUM )
	oProcess:oHtml:ValByName("USUARIO"		, SC7->C7_USER )
	oProcess:oHtml:ValByName("EMISSAO"		, SC7->C7_EMISSAO )
	oProcess:oHtml:ValByName("FORNECEDOR"	, SC7->C7_FORNECE )	                           
	oProcess:oHtml:ValByName("lb_nome"		, SA2->A2_NOME )
	oProcess:oHtml:ValByName("lb_cond"		, SE4->E4_DESCRI )
	oProcess:oHtml:ValByName("SCRAPRV"		, SCR->CR_APROV )
	oProcess:oHtml:ValByName("SCRNIVEL"		, SCR->CR_NIVEL )
	oProcess:oHtml:ValByName("CDEST"		, cDest )

	dBselectArea('SC7')
	dbSetOrder(1)
	dbSeek(cPedido)
	
	While !Eof() .and. SC7->C7_FILIAL+SC7->C7_NUM = cPedido
			
		AAdd( (oProcess:oHtml:ValByName( "produto.item" ))		,SC7->C7_ITEM )
		AAdd( (oProcess:oHtml:ValByName( "produto.codigo" ))	,SC7->C7_PRODUTO )
		AAdd( (oProcess:oHtml:ValByName( "produto.descricao" ))	,SC7->C7_DESCRI )
		AAdd( (oProcess:oHtml:ValByName( "produto.quant" ))		,TRANSFORM( SC7->C7_QUANT,'@E 99,999.99' ) )
		AAdd( (oProcess:oHtml:ValByName( "produto.unid" ))		,SC7->C7_UM )
		AAdd( (oProcess:oHtml:ValByName( "produto.preco" ))		,TRANSFORM( SC7->C7_PRECO,'@E 9,999,999.99' ) )
		AAdd( (oProcess:oHtml:ValByName( "produto.total" ))		,TRANSFORM( SC7->C7_TOTAL,'@E 9,999,999.99' ) )
		AAdd( (oProcess:oHtml:ValByName( "produto.cc" ))		,SC7->C7_CC )
		AAdd( (oProcess:oHtml:ValByName( "produto.cc" ))		,SC7->C7_CC )	
		AAdd( (oProcess:oHtml:ValByName( "produto.co" ))		,SC7->C7_CO )
		AAdd( (oProcess:oHtml:ValByName( "produto.areas" ))		,SC7->C7_ITEMCTA )		
		AAdd( (oProcess:oHtml:ValByName( "produto.ungestao" ))	,SC7->C7_CLVL )		
		WFSalvaID('SC7','C7_WFID',oProcess:fProcessID)
		
		IF !EMPTY(SC7->C7_OBS)
			cObs   += SC7->C7_ITEM+" - "+SC7->C7_OBS + " | "
		ENDIF
		
		nTotal += SC7->C7_TOTAL
	dbSkip()
	Enddo
		oProcess:oHtml:ValByName( "lb_aplic", cObs )	
		oProcess:oHtml:ValByName( "nTotal" ,TRANSFORM(nTotal,'@E 9,999,999.99' ) )

	//-------------------------------------------------------------------
	// Informamos em qual diretório será gerado o formulário.  
	//-------------------------------------------------------------------  	 
	oProcess:cTo 		:= "HTML"    

	//-------------------------------------------------------------------
	// Informamos qual função será executada no evento de timeout.  
	//-------------------------------------------------------------------  	
	oProcess:bTimeOut 	:= {{"u_WFCOMOUT(2)", 0, 0, 5 }}

	//-------------------------------------------------------------------
	// Informamos qual função será executada no evento de retorno.   
	//-------------------------------------------------------------------  	
	oProcess:bReturn 	:= "u_WFCOMRET()"

	//-------------------------------------------------------------------
	// Iniciamos a tarefa e recuperamos o nome do arquivo gerado.   
	//-------------------------------------------------------------------  
	cMailID := oProcess:Start()     

	//-------------------------------------------------------------------
	// "LINK"
	//------------------------------------------------------------------- 

	//-------------------------------------------------------------------
	// Criamos o ling para o arquivo que foi gerado na tarefa anterior.  
	//------------------------------------------------------------------- 	
	oProcess:NewTask("LINK", "\workflow\WF_LINKCOM.html")
	
	//-------------------------------------------------------------------
	// Atribuímos valor a um dos campos do formulário.  

	//------------------------------------------------------------------- 
	//oProcess:oHtml:ValByName("A_LINK", cHostWF + "/messenger/emp" + cEmpAnt + "/HTML/" + cMailId + ".htm")  
	oProcess:ohtml:ValByName("B_LINK", cHostWFB + "/messenger/emp" + cEmpAnt + "/HTML/" + cMailId + ".htm")
	
	//-------------------------------------------------------------------
	// Informamos o destinatário do email contendo o link.  
	//------------------------------------------------------------------- 	
	//cTo 		+= "everton.forti@totvs.com.br;"d
	oProcess:cTo 		:= ALLTRIM(cTo)
	//oProcess:CCC		:= "diorgny@conasa.com;"  
	
	//-------------------------------------------------------------------
	// Informamos o assunto do email.  
	//------------------------------------------------------------------- 	
	oProcess:cSubject	:= cAssunto

	//-------------------------------------------------------------------
	// Iniciamos a tarefa e enviamos o email ao destinatário.
	//------------------------------------------------------------------- 	
	oProcess:Start()   
	 
	IF lDEBUG
	RESET ENVIRONMENT   
	ENDIF                                                     		
Return    

//-------------------------------------------------------------------
/*/WFCOMRET    
Função executada no retorno do processo. 
/*/
//-------------------------------------------------------------------       
User Function WFCOMRET( poProcess )  
   	Local cTime 	:= ""
	Local cProcesso := ""  
	Local cTarefa	:= ""  
	Local cMailID	:= ""
	Local xChavSCR	:= ""
	Local cNumSC7	:= ""
	Local cUsrSC7	:= ""
	Local cMotivo	:= ""
	Local cAprov	:= ""
	Local cScrAp	:= ""	
	Local cNivel	:= ""	

	//-------------------------------------------------------------------
	// Recuperamos a hora do processo utilizando o método RetByName.
	//------------------------------------------------------------------- 		
	cTime 		:= poProcess:oHtml:RetByName('TEXT_TIME') 
	cNumSC7 	:= poProcess:oHtml:RetByName('PEDIDO')  
	cUsrSC7 	:= poProcess:oHtml:RetByName('USUARIO')  
	cMotivo 	:= poProcess:oHtml:RetByName('lbmotivo')    
	cAprov		:= poProcess:oHtml:RetByName('RBAPROVA')
	cScrAp		:= poProcess:oHtml:RetByName('SCRAPRV')
	cNivel		:= poProcess:oHtml:RetByName('SCRNIVEL')
	     	                                                 

	If valtype(cMotivo)<>"C".OR.cMotivo=Nil
		cMotivo := " "
	EndIf	     	

	dBselectArea('SC7')
	dbSetOrder(1)
	dbSeek(xFilial("SC7")+cNumSC7)
	
	xChavSCR:= xFilial("SCR")+"PC"+SC7->C7_NUM+SPACE(44)+cNivel
	                                               
	dBselectArea('SA2')
	dbSetOrder(1)
	dbSeek(xFilial("SA2")+SC7->C7_FORNECE)

	dBselectArea('SCR')
	dbSetOrder(1)
	if dbSeek(xChavSCR)
		CONOUT("Encontrou SCR")	
	else
		CONOUT("Não encontrou SCR")	
		Return()
	endif
	CONOUT(SCR->CR_NUM)
   
	While SCR->(!Eof()) .and. SCR->CR_FILIAL+"PC"+SCR->CR_NUM+SCR->CR_NIVEL = xChavSCR

	conout(cAprov)

		IF cAprov == "Sim" 
	 		conout('Aprova Pedido')	
					If RecLock("SCR",.f.)
					SCR->CR_DataLib := dDataBase
					SCR->CR_STATUS  := "05"
					SCR->CR_WF      := "S"
					SCR->CR_USERLIB := cScrAp
					SCR->CR_LIBAPRO := cScrAp
					SCR->CR_TIPOLIM := "D"
					MsUnLock()
					flag := "S"
					Endif
		 ELSEIF cAprov == "Nao"
	 		conout('Bloqueio de Pedido')
					If RecLock("SCR",.f.)
					SCR->CR_DataLib := dDataBase
					SCR->CR_OBS     := SUBSTR(cMotivo,1,60)
					SCR->CR_USERLIB := cScrAp
					SCR->CR_STATUS  := "04"
					SCR->CR_WF      := "S"
					SCR->CR_TIPOLIM := "D"
					MsUnLock()
					flag := "N"	 
					Endif
		 ENDIF			
    SCR->(dbSkip())
	Enddo   
	conout("SOMA1_NIVEL")
	//VERIFICA SE EXISTE MAIS NIVEIS A SER REENVIADO
	cNivel := SOMA1(alltrim(cNivel))
	cONOUT(cNivel)
	xChavSCR:= xFilial("SCR")+"PC"+SC7->C7_NUM+SPACE(44)+cNivel

	dBselectArea('SCR')
	dbSetOrder(1)
	if dbSeek(xChavSCR) .AND. flag == "S"
		//REENVIA PRÓXIMO NIVEL
		NEXTNIVEL(poProcess:oHtml,cNivel,xChavSCR,cNumSC7)
	ELSE
			//LIBERA PEDIDO DE COMPRA SC7
			while SC7->(!EOF()) .and. SC7->C7_NUM == cNumSC7
				IF cAprov == "Sim" 
						IF RecLock("SC7",.f.)
							SC7->C7_CONAPRO := "L"
						MsUnLock()
						ENDIF
						CONOUT("LIBERA PEDIDO DE COMPRA SC7")
				ELSEIF cAprov == "Nao" 
						IF RecLock("SC7",.f.)
							SC7->C7_CONAPRO := "R"
						MsUnLock()
						ENDIF
						CONOUT("BLOQUEIA PEDIDO DE COMPRA SC7")
				ENDIF
			SC7->(dbSkip())
			Enddo                
		
	ENDIF

		AvisaComprador(cNumSC7,flag,codfor,SA2->A2_NREDUZ,motivo,cUsrSC7)
	ConOut("--------------------A v i s a    C o m p r a d o r -------------------")
			
 	//-------------------------------------------------------------------
	// Recuperamos o identificador do email utilizando o método RetByName.
	//------------------------------------------------------------------- 		
	cMailID		:= poProcess:oHtml:RetByName("WFMAILID") 
  
	//-------------------------------------------------------------------
	// Recuperamos o ID do processo através do atributo do processo.
	//------------------------------------------------------------------- 		
	cProcesso 	:= poProcess:FProcessID  
 
	//-------------------------------------------------------------------
	// Recuperamos o ID da tarefa através do atributo do processo.
	//------------------------------------------------------------------- 	 
	cTarefa		:= poProcess:FTaskID  

	//-------------------------------------------------------------------
	// Exibe mensagem com dados do processamento no console.
	//-------------------------------------------------------------------                  
	Conout('Retorno do processo gerado às ' + cTime + " número " + cProcesso + ' ' + poProcess:oHtml:RetByName("WFMAILID") + ' tarefa ' + cTarefa + ' executado com sucesso!')
Return Nil    

//-------------------------------------------------------------------
/*/{Protheus.doc} WFCOMOUT    
Função executada no timeout do processo. 
/*/
//-------------------------------------------------------------------
User Function WFCOMOUT( poProcess )  
	//-------------------------------------------------------------------
	// Exibe mensagem com dados do processamento no console.
	//-------------------------------------------------------------------               
	Conout('Timeout do processo' + poProcess:FProcessID)  
Return Nil    

//-------------------------------------------------------------------
/*/{Protheus.doc} _WFPE007    
Permite customizar a mensagem de processamento do WF por link. 
/*/
//-------------------------------------------------------------------
User Function _WFPE007()
	Local cHTML 		:= ""
	Local plSuccess		:= ParamIXB[1] 
	Local pcMessage  	:= ParamIXB[2]	
	Local pcProcessID  	:= ParamIXB[3]
	
	If ( plSuccess ) 
		//-------------------------------------------------------------------
		// Mensagem em formato HTML para sucesso no processamento. 
		//------------------------------------------------------------------- 
    	cHTML += 'Resposta '+pcProcessID+' enviada ao servidor.!'
    	cHTML += '<br>'                                
       	cHTML += 'Processamento executado com sucesso!'
       	cHTML += '<br>'                                
    	cHTML += pcMessage
	Else       
		//-------------------------------------------------------------------
		// Mensagem em formato HTML para falha no processamento. 
		//------------------------------------------------------------------- 
    	cHTML += 'Resposta '+pcProcessID+' NÃO enviada ao servidor.!'
    	cHTML += '<br>'    
		cHTML += 'Falha no processamento!'
    	cHTML += '<br>'
    	cHTML += pcMessage
	EndIf
Return cHTML

//Envia e-mail para o comprador avisando da liberação do pedido.
Static Function AvisaComprador(nped,flag,codfor,nomefor,motivo,cUsrSC7)

Local oProcess
Local oHtml
conout("AvisaComprador")
oProcess := TWFProcess():New( "AVISO", "AVISO COMPRADOR" )

If flag == "S"
	oProcess:NewTask("Pedido Liberado" , "\WORKFLOW\PEDLIBERADO.HTM" )
	oProcess:cSubject := "Pedido Liberado n°. "+nped
EndIf
If flag == "N"
	oProcess:NewTask("Pedido Bloqueado" , "\WORKFLOW\PEDBLOQ.HTM" )
	oProcess:cSubject := "Pedido Bloqueado n°. "+nped
EndIf
conout("Aprovado"+flag)

oHTML := oProcess:oHTML
oHtml:ValByName( "pedido" , nped )
oHtml:ValByName( "codfor", codfor)
oHtml:ValByName( "fornecedor", nomefor)
If flag == "N"
	oHtml:ValByName( "motivo", motivo)
EndIF

	oProcess:cTo := UsrRetMail(cUsrSC7)         // Destinatario do Email do comprador
	//oProcess:cTo := "everton.forti@totvs.com.br;"//diorgny@conasa.com"          // Destinatario do Email do comprador

	oProcess:cTo := alltrim(GetMv("MV_UWFMAIL"))
oProcess:Start()
conout("Disparado")
Return

//U_NEXTNIVEL(0,"2 ","02PC000131"+SPACE(44)+"1 ","000131")
STATIC FUNCTION NEXTNIVEL(poProcess,cNivel,xChavSCR,cNumSC7)

//-------------------------------------------------------------------xFilial("SCR")+"PC"+SC7->C7_NUM+SPACE(44)+"1 "
//NEXTNIVEL - Função para envio do Workflow próximo nível
//-------------------------------------------------------------------  
	Local cMailId 	:= ""							//ID do processo gerado. 
	Local cHostWF	:= "http://192.168.0.60:8089"	//URL configurado no ini para WF Link. 
	Local cHostWFB	:= "http://protheus.conasa.com:8089"	//URL configurado no ini para WF Link. 
	Local cTo 		:= ""//"everton.forti@totvs.com.br;" 	//Destinatário de email.    
	Local nTotal	:= 0 
	Local cObs		:= ""
	Local lDEBUG	:= .F.
	Local cDest		:= ""
	Local cAssunto  := "Workflo Pedido de Compras"	

	CONOUT("NEXTNIVEL")
	//conout(cNivel)
	conout(xChavSCR)
	conout(cNumSC7)
	//-------------------------------------------------------------------
	// "FORMULARIO"
	//-------------------------------------------------------------------  	
	
	dBselectArea('SC7')//PEDIDO COMPRA
	dbSetOrder(1)
	dbSeek(xFilial("SC7")+cNumSC7)
	
	dBselectArea('SCR')
	dbSetOrder(1)
	if dbSeek(xChavSCR)
		CONOUT("Encontrou SCR")	
		WHILE SCR->(!EOF()) .AND. SCR->CR_FILIAL+SCR->CR_TIPO+SCR->CR_NUM+SCR->CR_NIVEL == xChavSCR
			cTo += UsrRetMail(SCR->CR_USER)+";"
			cDest += UsrRetMail(SCR->CR_USER)+";"
		SCR->(DBSKIP())
		ENDDO
	else
		CONOUT("Não encontrou SCR")	
		Return()
	endif

	dBselectArea('SCR')//ALCADAS PED.COMRA
	dbSetOrder(1)
	dbSeek(xChavSCR)
                      
	dBselectArea('SA2')//FORNECEDORES
	dbSetOrder(1)
	dbSeek(xFilial("SA2")+SC7->C7_FORNECE)
	
	dbSelectArea('SE4')//COND.PAGAMENTO
	dbSetOrder(1)
	dbSeek(xFilial('SE4')+SC7->C7_COND)
	
	dbSelectArea('SAK')//APROVADORES
	dbSetOrder(1)
	dbSeek(xFilial('SAK')+SCR->CR_APROV)

	cAssunto  := "Workflow Compras "+Alltrim(SM0->M0_NOME) + " - "+ alltrim(SM0->M0_FILIAL) +" - Pedido:  "+Substr(cNumSC7,3,6)+"-"+SA2->A2_NREDUZ
	//-------------------------------------------------------------------
	// Instanciamos a classe TWFProcess informando o código e nome do processo.  
	//-------------------------------------------------------------------  
	poProcess := TWFProcess():New("000001", cAssunto)

	//-------------------------------------------------------------------
	// Criamos a tafefa principal que será respondida pelo usuário.  
	//-------------------------------------------------------------------  
	poProcess:NewTask("FORMULARIO", "\Workflow\WF_FORMCOM.html")

	//-------------------------------------------------------------------
	// Atribuímos valor a um dos campos do formulário.  
	//-------------------------------------------------------------------  	   
	poProcess:oHtml:ValByName("TEXT_TIME"	, Time() )
	poProcess:oHtml:ValByName("EMPRESA"		, SM0->M0_NOMECOM )
	poProcess:oHtml:ValByName("PEDIDO"		, SC7->C7_NUM )
	poProcess:oHtml:ValByName("USUARIO"		, SC7->C7_USER )
	poProcess:oHtml:ValByName("EMISSAO"		, SC7->C7_EMISSAO )
	poProcess:oHtml:ValByName("FORNECEDOR"	, SC7->C7_FORNECE )	                           
	poProcess:oHtml:ValByName("lb_nome"		, SA2->A2_NOME )
	poProcess:oHtml:ValByName("lb_cond"		, SE4->E4_DESCRI )
	poProcess:oHtml:ValByName("SCRAPRV"		, SCR->CR_APROV )
	poProcess:oHtml:ValByName("SCRNIVEL"	, SCR->CR_NIVEL )
	poProcess:oHtml:ValByName("CDEST"		, cDest )

	dBselectArea('SC7')
	dbSetOrder(1)
	dbSeek(xFilial("SC7")+cNumSC7)
	
	While !Eof() .and. SC7->C7_NUM = cNumSC7
			
		AAdd( (poProcess:oHtml:ValByName( "produto.item" ))			,SC7->C7_ITEM )
		AAdd( (poProcess:oHtml:ValByName( "produto.codigo" ))		,SC7->C7_PRODUTO )
		AAdd( (poProcess:oHtml:ValByName( "produto.descricao" ))	,SC7->C7_DESCRI )
		AAdd( (poProcess:oHtml:ValByName( "produto.quant" ))		,TRANSFORM( SC7->C7_QUANT,'@E 99,999.99' ) )
		AAdd( (poProcess:oHtml:ValByName( "produto.unid" ))			,SC7->C7_UM )
		AAdd( (poProcess:oHtml:ValByName( "produto.preco" ))		,TRANSFORM( SC7->C7_PRECO,'@E 9,999,999.99' ) )
		AAdd( (poProcess:oHtml:ValByName( "produto.total" ))		,TRANSFORM( SC7->C7_TOTAL,'@E 9,999,999.99' ) )
		AAdd( (poProcess:oHtml:ValByName( "produto.cc" ))			,SC7->C7_CC )
		AAdd( (poProcess:oHtml:ValByName( "produto.cc" ))			,SC7->C7_CC )	
		AAdd( (poProcess:oHtml:ValByName( "produto.co" ))			,SC7->C7_CO )
		AAdd( (poProcess:oHtml:ValByName( "produto.areas" ))		,SC7->C7_ITEMCTA )		
		AAdd( (poProcess:oHtml:ValByName( "produto.ungestao" ))		,SC7->C7_CLVL )		
		WFSalvaID('SC7','C7_WFID',poProcess:fProcessID)
		cObs   += SC7->C7_ITEM+" - "+SC7->C7_OBS + " | "
		nTotal += SC7->C7_TOTAL
	dbSkip() 
	Enddo
		poProcess:oHtml:ValByName( "lb_aplic", cObs )	
		poProcess:oHtml:ValByName( "nTotal" ,TRANSFORM(nTotal,'@E 9,999,999.99' ) )

	//-------------------------------------------------------------------
	// Informamos em qual diretório será gerado o formulário.  
	//-------------------------------------------------------------------  	 
	poProcess:cTo 		:= "HTML"    

	//-------------------------------------------------------------------
	// Informamos qual função será executada no evento de timeout.  
	//-------------------------------------------------------------------  	
	poProcess:bTimeOut 	:= {{"u_WFCOMOUT(2)", 0, 0, 5 }}

	//-------------------------------------------------------------------
	// Informamos qual função será executada no evento de retorno.   
	//-------------------------------------------------------------------  	
	poProcess:bReturn 	:= "u_WFCOMRET()"

	//-------------------------------------------------------------------
	// Iniciamos a tarefa e recuperamos o nome do arquivo gerado.   
	//-------------------------------------------------------------------  
	cMailID := poProcess:Start()     

	//-------------------------------------------------------------------
	// "LINK"
	//------------------------------------------------------------------- 

	//-------------------------------------------------------------------
	// Criamos o ling para o arquivo que foi gerado na tarefa anterior.  
	//------------------------------------------------------------------- 	
	poProcess:NewTask("LINK", "\workflow\WF_LINKCOM.html")
	
	//-------------------------------------------------------------------
	// Atribuímos valor a um dos campos do formulário.  
	//------------------------------------------------------------------- 
	poProcess:oHtml:ValByName("A_LINK", cHostWF + "/messenger/emp" + cEmpAnt + "/HTML/" + cMailId + ".htm")  
	poProcess:ohtml:ValByName("B_LINK", cHostWFB + "/messenger/emp" + cEmpAnt + "/HTML/" + cMailId + ".htm")
	
	//-------------------------------------------------------------------
	// Informamos o destinatário do email contendo o link.  
	//------------------------------------------------------------------- 
	poProcess:cTo 		:= cTo   
	//poProcess:CCC		:= "everton.forti@totvs.com.br;diorgny@conasa.com;"   
	
	//-------------------------------------------------------------------
	// Informamos o assunto do email.  
	//------------------------------------------------------------------- 	
	poProcess:cSubject	:= cAssunto

	//-------------------------------------------------------------------
	// Iniciamos a tarefa e enviamos o email ao destinatário.
	//------------------------------------------------------------------- 	
	poProcess:Start()   

	IF lDEBUG
	RESET ENVIRONMENT
	ENDIF                                           		



RETURN()
