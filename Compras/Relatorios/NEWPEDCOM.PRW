/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³BRACOM01  ºAutor Everton Forti         º Data ³ 30/09/2022  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Impressão do pedido de compras                              º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
#INCLUDE "TOPCONN.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "TBICODE.CH"
#INCLUDE "AP5MAIL.CH"

#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "RPTDEF.CH"
#INCLUDE "FWPRINTSETUP.CH"

#DEFINE Imp_Spool      	2
#DEFINE ALIGN_H_LEFT   	0
#DEFINE ALIGN_H_RIGHT  	1
#DEFINE ALIGN_H_CENTER 	2
#DEFINE ALIGN_V_CENTER 	0
#DEFINE ALIGN_V_TOP	   	1
#DEFINE ALIGN_V_BOTTON 	2

#DEFINE Imp_Spool      	2
#DEFINE ALIGN_H_LEFT   	0
#DEFINE ALIGN_H_RIGHT  	1
#DEFINE ALIGN_H_CENTER 	2
#DEFINE ALIGN_V_CENTER 	0
#DEFINE ALIGN_V_TOP	   	1
#DEFINE ALIGN_V_BOTTON 	2
#DEFINE oFontc08 		TFont():New( "Calibri", , 07, , .F., , , , , .F., .F. )
#DEFINE oFontc08n 		TFont():New( "Calibri", , 07, , .T., , , , , .F., .F. )
#DEFINE oFontc12 		TFont():New( "Calibri", , 12, , .F., , , , , .F., .F. )
#DEFINE oFontc12n 		TFont():New( "Calibri", , 12, , .T., , , , , .F., .F. )

//IMPRESSÃO DO PC
USER FUNCTION NEWPEDCOM()

		U_BRACOM01(CFILANT,SC7->C7_NUM,SC7->C7_NUM,.F.)

RETURN()

//ENVIO DO PC
USER FUNCTION BRACM01B()
	LOCAL CPCFORN := "N"

		IF CPCFORN == "S"
			IF MSGBOX("Confirma o envio por e-mail do pedido posicionado para o fornecedor ?","Atenção","YESNO")
				U_BRACOM01(CFILANT,SC7->C7_NUM,SC7->C7_NUM,.T.)
				MSGBOX("Pedido enviado com sucesso !","Atenção","INFO")
			ENDIF
		ELSE
			IF MSGBOX("Confirma o envio por e-mail do pedido posicionado ? (Obs. por enquanto não vai para o fornecedor)","Atenção - MV_UPCFORN","YESNO")
				U_BRACOM01(CFILANT,SC7->C7_NUM,SC7->C7_NUM,.T.)
				MSGBOX("Pedido enviado com sucesso !","Atenção","INFO")
			ENDIF
		ENDIF
	
RETURN()

USER FUNCTION BRACOM01(CFILPED,CNUMINI,CNUMFIM,LPDFEMAIL)
	PRIVATE	AAREA_SC7	:=	SC7->(GETAREA())
	PRIVATE	OPRINTER	:=	NIL
	PRIVATE	CNOMECOM	:=	""
	PRIVATE	CPCFORN		:=	"N"
	PRIVATE	oBrush1		:=	TBrush():New(,CLR_HGRAY)
	PRIVATE	cMailFor	:=	""
	PRIVATE oUser       := nil
	PRIVATE	nLin		:=	0
	PRIVATE	nNumPg		:=	1
	PRIVATE	aTpfrete	:=	{{" ","Não Informado"},{"C","CIF"},{"F","FOB"},{"T","Por conta terceiros"},{"D","Por conta destinatário"},{"R","Por conta remetente"},{"S","Sem frete"}}
	PRIVATE	cTpFrete	:=	""
	PRIVATE OSERVER
	PRIVATE cLocal 		:= ""
	PRIVATE cFilePrint
	PRIVATE xHeight 	:= 595			//SetPortrait()=815; SetLandscape()=620; 
	PRIVATE xWidth  	:= 825 			//SetPortrait()=580; SetLandscape()=825;
    PRIVATE nQtdLin     := 563

	PRIVATE CMAIL := "everton.forti@totvs.com.br "//GETMV("MV_UMAILPC") //DESTINATÁRIOS DO E-MAIL

	DEFAULT	LPDFEMAIL	:=	.F.
	
	SM0->(DBSETORDER(1))
	SM0->(DBSEEK(CEMPANT+CFILANT))


	//INICIO: Obtem dados dos usuários comprador 
	oUser := tcUser():New()
	oUser:FindByID(alltrim("Nome do Comprador"))
	if oUser:Available()
		CNOMECOM := oUser:GetUserName()
	endIf
	oUser:Destroy()
	//TÉRMINO: Obtem dados dos usuários comprador 

	CPCFORN := "N"

	SB1->(DBSETORDER(1))
	SCR->(DBSETORDER(1))
	SE4->(DBSETORDER(1))
	SA2->(DBSETORDER(1))
	SB1->(DBSETORDER(1))
	SC7->(DBSETORDER(1))

	SC7->(DBSEEK(CFILPED+CNUMINI,.T.))

	cLocal     := getTempPath()
	cFilePrint := "PEDIDO_"+ALLTRIM(SC7->C7_NUM)+"_"+DTOS(DATE())+"_"+STRTRAN(TIME(),":","_")+'.pdf'

	oPrinter := fwMsPrinter():New(cFilePrint, IMP_PDF, .f., cLocal, .t.,,,,,, .f.,)
    oPrinter:SetLandscape()//oPrinter:SetPortrait()
	oPrinter:SetResolution(72)

        processa({ || PUTBODY() })

	//geração do relatório em PDF
	file2Printer(cLocal + cFilePrint, "pdf" )
	oPrinter:cPathPDF := cLocal 
	
	If lPDFEmail

		oPrinter:Print()
		
		Sleep(5000)

		//copia o arquivo para o servidor para poder ser anexado
		CpyT2S(cLocal+cFilePrint,"\pedcompra")

		//U_MAIL()

		oMessage := TMailMessage():New()
		oMessage:Clear()
		oMessage:cFrom          := SUPERGETMV("MV_RELFROM",.F.,"everton.forti@totvs.com.br") 
		If CPCFORN == "S"
			oMessage:cTo        := "everton.forti@totvs.com.br"
			oMessage:cCc        := ""
			oMessage:cBcc       := ""
			oMessage:cSubject   := IIf(Empty(cMailFor),"FORNECEDOR SEM E-MAIL","Pedido de compra Brandt")
		Else
			oMessage:cTo        := "Rafael.Silva@Brandt.Co"
			oMessage:cCc        := ""
			oMessage:cBcc       := ""
			oMessage:cSubject   := "everton.forti@totvs.com.br"
		EndIf

		oMessage:cBody := "Segue em anexo um pedido de compras."


		if oMessage:AttachFile("\pedcompra\"+cFilePrint) < 0
			Alert("Não consegui anexar o arquivo ao e-mail !")
		endif

		nRet := oMessage:Send( oServer )

		If nRet == 0
			conout("SendMail Sucess")
		Else
			conout(nret)
			Alert(oServer:GetErrorString(nRet),"Send","ERROR")
		Endif

		nRet := oServer:SmtpDisconnect()
		If nRet == 0
			conout("Disconnect Sucess")
		Else
			conout(nret)
			conout(oServer:GetErrorString(nret))
		Endif

	Else
		//oPrinter:Print()
		oPrinter:Preview()
	EndIF

	FreeObj(oPrinter)
	oPrinter := Nil

	RESTAREA(AAREA_SC7)

RETURN

STATIC FUNCTION PUTBODY()
	LOCAL I := 0
    LOCAL cCusto    := ""
    LOCAL cCo       := ""
    Local cClvl     := ""
	//LOCAL Q4 := 0
	//LOCAL PLUS := 0

	procRegua(0)
	incProc("Imprimindo...")

	SA2->(DBSEEK(XFILIAL("SA2")+SC7->C7_FORNECE+SC7->C7_LOJA))
	cMailFor := AllTrim(SA2->A2_EMAIL)
	
	SA2->(DBSEEK(XFILIAL("SA2")+SC7->C7_FORNECE+SC7->C7_LOJA))
	SE4->(DBSEEK(XFILIAL("SE4")+SC7->C7_COND))
	SCR->(DBSEEK(XFILIAL("SCR")+"PC"+SC7->C7_NUM))

	cObs		:=	""
	nTotReal	:=	0
	nTotDolar	:=	0
	nTotIcms	:=	0
	nTotIpi		:=	0
	cTpFrete	:=	SC7->C7_TPFRETE
	nTxMoedaPC	:=	SC7->C7_TXMOEDA
	vFrete      :=  SC7->C7_DESPESA
	nTotLiqReal :=  0 //Inclusão feita por Osires aos 28 dias de Dez/2021
	nItTotLiqReal:= 0
	nValDesc	:=  0
	nTotDesc    := 0
	

	CabPed(oPrinter,cNomeCom,oBrush1)

	cChaveSC7 := SC7->C7_FILIAL+SC7->C7_NUM

	WHILE !SC7->(EOF()) .AND. SC7->C7_FILIAL+SC7->C7_NUM == cChaveSC7
		/*If Empty(SC7->C7_SEGUM)
			nItQtd	:= SC7->C7_QUANT
		Else
			nItQtd	:= SC7->C7_QTSEGUM
		EndIf*/ 
		nItQtd	    := SC7->C7_QUANT
        cCusto      := SC7->C7_CC
        cCo         := SC7->C7_CO
        cClvl       := SC7->C7_CLVL 
		SB1->(DBSEEK(XFILIAL("SB1")+SC7->C7_PRODUTO))
		If SC7->C7_MOEDA == 1
			nItTotReal  := SC7->C7_TOTAL  
			/*If Empty(SC7->C7_SEGUM)
				nItPrcReal  := SC7->C7_PRECO
			Else
				nItPrcReal  := Round(nItTotReal / nItQtd,4)
			EndIf*/  
			
			nItPrcReal  := SC7->C7_PRECO
		//Else //MINHA INCLUSÃO - OSIRES
			If SC7->C7_MOEDA == 1 .AND. SC7->C7_VLDESC > 0
				nValDesc  := SC7->C7_VLDESC
			EndIf
			If SC7->C7_MOEDA == 1 .AND. SC7->C7_VLDESC > 0
				nItTotLiqReal  := (SC7->C7_TOTAL - nValDesc) 
			EndIf
			
		Else
			/*nItTotReal  := IIF(SC7->C7_TXMOEDA > 0,SC7->C7_TOTAL*SC7->C7_TXMOEDA,0)    
			If Empty(SC7->C7_SEGUM)
				nItPrcReal  := IIF(SC7->C7_TXMOEDA > 0,SC7->C7_PRECO*SC7->C7_TXMOEDA,0)
			Else
				nItPrcReal  := IIF(SC7->C7_TXMOEDA > 0,(nItTotReal / nItQtd) * SC7->C7_TXMOEDA,0)
			EndIf */ 
			
			nItTotReal  := IIF(SC7->C7_TXMOEDA > 0,SC7->C7_TOTAL*SC7->C7_TXMOEDA,0)    
			nItPrcReal  := IIF(SC7->C7_TXMOEDA > 0,SC7->C7_PRECO*SC7->C7_TXMOEDA,0)
		EndIf
		nTotReal     += nItTotReal
		nTotLiqReal  += nItTotLiqReal
		nTotDesc     += nValDesc

		nTotIcms  += SC7->C7_VALICM
		nTotIpi   += SC7->C7_VALIPI

		oPrinter:SayAlign(nLin,0012,RTRIM(SC7->C7_PRODUTO),oFontc08,0060,005, /*cor*/, 0, 1 )
		oPrinter:SayAlign(nLin,0070,RTRIM(SB1->B1_DESC),oFontc08,0350,005, /*cor*/, 0, 1 )
		oPrinter:SayAlign(nLin,0450,TRANSFORM(nItQtd,"@E 9,999,999.99"),oFontc08,0060,005, /*cor*/, 0, 1 )
		//oPrinter:SayAlign(nLin,0480,IIF(EMPTY(SC7->C7_SEGUM),SC7->C7_UM,SC7->C7_SEGUM),oFontc08,0020,005, /*cor*/, 0, 1 )
		oPrinter:SayAlign(nLin,0410,RTRIM(SC7->C7_UM),oFontc08,0020,005, /*cor*/, 0, 1 )
		oPrinter:SayAlign(nLin,0500,TRANSFORM(nItPrcReal,"@E 9,999,999.9999"),oFontc08,0070,005, /*cor*/, 0, 1 )
		oPrinter:SayAlign(nLin,0570,TRANSFORM(nItTotReal,"@E 9,999,999.99"),oFontc08,0060,005, /*cor*/, 0, 1 )
		//oPrinter:SayAlign(nLin,0570,TRANSFORM(nItTotLiqReal,"@E 9,999,999.99"),oFontc08,0060,005, /*cor*/, 1, 1 )
		//oPrinter:SayAlign(nLin,0570,TRANSFORM(nTotDesc,"@E 9,999,999.99"),oFontc08,0060,005, /*cor*/, 1, 1 )
		oPrinter:SayAlign(nLin,0630,cCusto,oFontc08,0070,005, /*cor*/, 0, 1 )
		oPrinter:SayAlign(nLin,0700,cCo,oFontc08,0060,005, /*cor*/, 0, 1 )
		oPrinter:SayAlign(nLin,0750,cClvl,oFontc08,0060,005, /*cor*/, 0, 1 )
		oPrinter:SayAlign(nLin,0790,DTOC(SC7->C7_DATPRF),oFontc08,0060,005, /*cor*/, 0, 1 )

		nLin += 13
		If nLin > nQtdLin
			oPrinter:EndPage()
			CabPed(oPrinter,cNomeCom,oBrush1)
			//nLin := 0134
		EndIf
		/*aGarantia := fGarantia()
		If Len(aGarantia) > 0
			For I := 1 To Len(aGarantia)
				If I == 1
					oPrinter:SayAlign(nLin,0010,"Garantia:",oFontc08,0060,005, "", 0, 1 )
				EndIf
				oPrinter:SayAlign(nLin,070,aGarantia[I],oFontc08,1000,005, "", 0, 1 )
				nLin += 13
				If nLin > nQtdLin
					oPrinter:EndPage()
					CabPed(oPrinter,cNomeCom,oBrush1)
					//nLin := 0134
				EndIf
			Next
		EndIf
        */
		oPrinter:Line(nLin,0008,nLin,xWidth+5,0,"-1")
		cObs += Rtrim(SC7->C7_OBS)
		SC7->(DBSKIP())
	ENDDO

	If nLin > nQtdLin
		SC7->(DBSKIP(-1))
		oPrinter:EndPage()
		CabPed(oPrinter,cNomeCom,oBrush1)
		SC7->(DBSKIP())
	EndIf

	oPrinter:Line(0450,0008,0450,xWidth+5,0,"-1")
	oPrinter:SayAlign(0463,0010,"Observação:",oFontc08n,0060,005, /*cor*/, 0, 1 )
	nRod := 463
	nLin := 476
	For I := 1 To Len(cObs) Step 80
		oPrinter:SayAlign(nLin,0010,Substr(cObs,I,80),oFontc08,0400,005, /*cor*/, 0, 1 )
		nLin+=13
	Next
	oPrinter:SayAlign(nRod,0280,"Valor total do pedido R$",oFontc08n,0160,005, /*cor*/, 1, 1 )
	oPrinter:SayAlign(nRod,0485,TRANSFORM(nTotReal,"@E 9,999,999.99"),oFontc08n,0060,005, /*cor*/, 0, 1 )
	nRod+=13
	oPrinter:SayAlign(nRod,0280,"Valor total do pedido U$",oFontc08n,0160,005, /*cor*/, 1, 1 )
	oPrinter:SayAlign(nRod,0485,TRANSFORM(nTotDolar,"@E 9,999,999.99"),oFontc08n,0060,005, /*cor*/, 0, 1 )
	nRod+=13
	oPrinter:SayAlign(nRod,0280,"Valor de Frete",oFontc08n,0160,005, /*cor*/, 1, 1 )
	oPrinter:SayAlign(nRod,0485,TRANSFORM(vFrete,"@E 9,999,999.99"),oFontc08n,0060,005, /*cor*/, 0, 1 )
	nRod+=13
	oPrinter:SayAlign(nRod,0280,"Valor Desconto R$",oFontc08n,0160,005, /*cor*/, 1, 1 )
	oPrinter:SayAlign(nRod,0485,TRANSFORM(nTotDesc,"@E 9,999,999.99"),oFontc08n,0060,005, /*cor*/, 0, 1 )
	nRod+=13
	oPrinter:SayAlign(nRod,0280,"Valor Total Liq. R$",oFontc08n,0160,005, /*cor*/, 1, 1 )
	oPrinter:SayAlign(nRod,0485,TRANSFORM(nTotLiqReal,"@E 9,999,999.99"),oFontc08n,0060,005, /*cor*/, 0, 1 )
	nRod+=13
	
	//oPrinter:SayAlign(nRod,0610,"Valor total de IPI",oFontc08n,0160,005, /*cor*/, 1, 1 )
	//oPrinter:SayAlign(nRod,0790,TRANSFORM(nTotIpi,"@E 9,999,999.99"),oFontc08n,0060,005, /*cor*/, 0, 1 )
	nRod+=13
	nLin:=nRod
	oPrinter:Line(nLin,0008,nLin,xWidth+5,0,"-1")
	nLin+=13
	oPrinter:SayAlign(nLin,0010,"MODALIDADE DE FRETE:",oFontc08n,0100,005, /*cor*/, 0, 1 )
	oPrinter:SayAlign(nLin,0110,aTpfrete[aScan(aTpFrete,{|x| x[1]==cTpFrete}),2],oFontc08n,0160,005, /*cor*/, 0, 1 )
	nLin+=13
	oPrinter:SayAlign(nLin,0010,"TRANSPORTADORA:",oFontc08n,0400,005, /*cor*/, 0, 1 )
	oPrinter:SayAlign(nLin,0110,"",oFontc08n,0160,005, /*cor*/, 0, 1 )
	nLin+=26
	oPrinter:SayAlign(nLin,0010,"NOTAS EM DESACORDO COM O TERMO DE FORNECIMENTO PODERÃO SER RECUSADAS SEM AVISO PRÉVIO",oFontc08n,0500,005, /*cor*/, 0, 1 )

	oPrinter:EndPage()

RETURN

STATIC FUNCTION CABPED(oPrinter,cNomeCom,oBrush1)
	local cNomAprov := ""
	local oUser     := tcUser():New()

	dbSelectArea("SAK")
	SAK->(dbSetOrder(1))	//AK_FILIAL+AK_COD

	if SAK->(dbSeek(xFilial("SAK") + SCR->CR_APROV))
		oUser:FindByID(SAK->AK_USER)
	
		if oUser:Available()
			cNomAprov += oUser:GetName()
		endIf
	endIf

	oUser:Destroy()

	nLin		:=	20
	oPrinter:StartPage()
	oPrinter:Box(NLIN,0008,xHeight,xWidth+5)
	NLIN += 10
	oPrinter:SayBitmap(NLIN+20,0015, "LGMID"+SUBSTR(CNUMEMP,1,2)+".png" ,50,50)  

	oPrinter:SayAlign(NLIN,0130,"DADOS DO COMPRADOR",oFontc08n,0180,005, /*cor*/, 0, 1 )
	oPrinter:SayAlign(NLIN,0330,"DADOS DO FORNECEDOR",oFontc08n,0200,005, /*cor*/, 0, 1 )
	oPrinter:SayAlign(NLIN,0520,"DATA DO PEDIDO: "+DTOC(SC7->C7_EMISSAO),oFontc08,0180,005, /*cor*/, 0, 1 )
	oPrinter:SayAlign(NLIN,0665,"Pedido de Compra: ",oFontc12n,0160,005, /*cor*/, 0, 1 )
	
	NLIN += 13

	oPrinter:SayAlign(NLIN,0130,SUBSTR(RTRIM(SM0->M0_NOMECOM),1,33),oFontc08,0180,005, /*cor*/, 0, 1 )
	oPrinter:SayAlign(NLIN,0330,RTRIM(SA2->A2_NOME),oFontc08,0200,005, /*cor*/, 0, 1 )
	oPrinter:SayAlign(NLIN,0520,"USUÁRIO: "+LEFT(USRFULLNAME(SC7->C7_USER),15),oFontc08,0180,005, /*cor*/, 0, 1 )
	oPrinter:SayAlign(NLIN,0660,SC7->C7_NUM,oFontc12n,0130,005, /*cor*/, 0, 1 )

	NLIN += 13

	oPrinter:SayAlign(NLIN,0130,"CNPJ: "+TRANSFORM(RTRIM(SM0->M0_CGC),"@R 99.999.999/9999-99"),oFontc08,0180,005, /*cor*/, 0, 1 )
	oPrinter:SayAlign(NLIN,0330,"CNPJ: "+TRANSFORM(RTRIM(SA2->A2_CGC),IIF(SA2->A2_TIPO=="J","@R 99.999.999/9999-99","@R 999.999.999-99")),oFontc08,0200,005, /*cor*/, 0, 1 )
	oPrinter:SayAlign(NLIN,0520,"Pagto: "+RTRIM(SE4->E4_DESCRI),oFontc08,0180,005, /*cor*/, 0, 1 )

	NLIN += 13

	oPrinter:SayAlign(NLIN,0130,"IE: "+RTRIM(SM0->M0_INSC),oFontc08,0180,005, /*cor*/, 0, 1 )
	oPrinter:SayAlign(NLIN,0330,"IE: "+RTRIM(SA2->A2_INSCR),oFontc08,0200,005, /*cor*/, 0, 1 )
	oPrinter:SayAlign(NLIN,0520,"Página: "+StrZero(nNumPg++,2),oFontc08,0140,005, /*cor*/, 0, 1 )

	NLIN += 13

	oPrinter:SayAlign(NLIN,0130,"CEP: "+SUBSTR(SM0->M0_CEPENT,1,5)+"-"+SUBSTR(SM0->M0_CEPENT,6,3),oFontc08,0180,005, /*cor*/, 0, 1 )
	oPrinter:SayAlign(NLIN,0330,"CEP: "+SUBSTR(SA2->A2_CEP,1,5)+"-"+SUBSTR(SA2->A2_CEP,6,3),oFontc08,0200,005, /*cor*/, 0, 1 )
	//oPrinter:SayAlign(NLIN,0520,"Status do pedido: "+fStatus(),oFontc08,0180,005, /*cor*/, 0, 1 )

	NLIN += 13

    oPrinter:SayAlign(NLIN,0130,RTRIM(SM0->M0_TEL),oFontc08,0180,005, /*cor*/, 0, 1 )
	oPrinter:SayAlign(NLIN,0330,RTRIM(SA2->A2_END )+", "+RTRIM(SA2->A2_NR_END)+" "+RTRIM(SA2->A2_MUN)+" "+RTRIM(SA2->A2_EST),oFontc08,0200,005, /*cor*/, 0, 1 )
	//oPrinter:SayAlign(NLIN,0520,"Taxa da moeda: "+ALLTRIM(TRANSFORM(nTxMoedaPC,"@E 99.9999")),oFontc08,0180,005, /*cor*/, 0, 1 )

	NLIN += 13
    
    oPrinter:SayAlign(NLIN,0130,RTRIM(SM0->M0_ENDENT)+", "+RTRIM(SM0->M0_CIDENT)+" "+RTRIM(SM0->M0_ESTENT),oFontc08,0180,005, /*cor*/, 0, 1 )
	oPrinter:SayAlign(NLIN,0330,RTRIM(SA2->A2_DDD)+IIF(EMPTY(SA2->A2_DDD),""," ")+RTRIM(SA2->A2_TEL),oFontc08,0180,005, /*cor*/, 0, 1 )


	NLIN += 13

	oPrinter:Fillrect( {NLIN,009,NLIN+12,xWidth+4}, oBrush1, "-2")                                                       

	oPrinter:SayAlign(NLIN,0012,"CÓD ITEM",oFontc08n,0060,005, /*cor*/, 0, 1 )
	oPrinter:SayAlign(NLIN,0070,"DESCRIÇÃO",oFontc08n,0100,005, /*cor*/, 0, 1 )
	oPrinter:SayAlign(NLIN,0410,"UM",oFontc08n,0020,005, /*cor*/, 0, 1 )
	oPrinter:SayAlign(NLIN,0470,"QTD",oFontc08n,0060,005, /*cor*/, 0, 1 )
	oPrinter:SayAlign(NLIN,0500,"UNITÁRIO R$",oFontc08n,0070,005, /*cor*/, 0, 1 )
	oPrinter:SayAlign(NLIN,0570,"TOTAL R$",oFontc08n,0060,005, /*cor*/, 0, 1 )
	oPrinter:SayAlign(NLIN,0630,"C.CUSTO",oFontc08n,0070,005, /*cor*/, 0, 1 )
	oPrinter:SayAlign(NLIN,0700,"C.O.",oFontc08n,0060,005, /*cor*/, 0, 1 )
	oPrinter:SayAlign(NLIN,0750,"CLVL",oFontc08n,0060,005, /*cor*/, 0, 1 )
	oPrinter:SayAlign(NLIN,0790,"ENTREGA",oFontc08n,0060,005, /*cor*/, 0, 1 )
	//Centro de Custo | Descrição do Centro de Custo | Conta Orçamentaria | Descrição da Conta Orçamentaria | Classe de Valor | Descrição da Classe de Valor
	nLin += 13

RETURN()

STATIC FUNCTION FGARANTIA()
	LOCAL I      := 0
	LOCAL ARET   :=	{}
	LOCAL XRET   :=	""
	LOCAL NCONTA := 0

	QE6->(DbSetOrder(3))
	QE6->(DbSeek(xFilial("QE6")+SC7->C7_PRODUTO+"ZZ",.T.))
	QE6->(DbSkip(-1))
	If QE6->QE6_FILIAL+QE6->QE6_PRODUT == xFilial("QE6")+SC7->C7_PRODUTO
		cRet := QE6->QE6_UGARAN
		xRet := ""
		For I := 1 To Len(cRet) Step 1
			If Substr(cRet,I,1) == Chr(10) .OR. Substr(cRet,I,1) == Chr(13)
				If !Empty(xRet)
					IF EMPTY(aRet) .OR. NCONTA == 0
						aadd(aRet,xRet)
						NCONTA += 1
					ELSE
						ARET[LEN(aRet)] += " | "+ALLTRIM(xRet)
						NCONTA += 1
					ENDIF
					IF NCONTA == 5
						NCONTA := 0
					ENDIF
				EndIf
				xRet := ""
			Else
				xRet += Substr(cRet,I,1) 
			EndIf 
		Next 
	EndIf 

RETURN(aRet)

STATIC FUNCTION fStatus()
	Local	cRet	:=	""

	//STAUTS DA APROVAÇÃO DO PEDIDO
	DBSELECTAREA("SCR")
	SCR->(DBSETORDER(1))
	IF SCR->(DBSEEK(XFILIAL("SCR")+"PC"+SC7->C7_NUM))
		IF SCR->CR_STATUS='01'
			cRet := "Bloqueado (aguardando outros níveis)"
		ELSEIF SCR->CR_STATUS='02'
			cRet := "Aguardando Liberação do usuário
		ELSEIF SCR->CR_STATUS='03'
			//cRet := "Documento Liberado pelo usuário"
			cRet := "Aprovado"
		ELSEIF SCR->CR_STATUS='04'
			cRet := "Documento Bloqueado pelo usuário"
		ELSEIF SCR->CR_STATUS='05'
			//cRet := "Documento Liberado por outro usuário"
			cRet := "Aprovado"
		ELSEIF SCR->CR_STATUS='06'
			cRet := "Documento Rejeitado pelo usuário"
		ELSEIF SCR->CR_STATUS='07'
			cRet := "Documento Rejeitado ou Bloqueado por outro usuário"
		ENDIF
	ELSE
		cRet := "Falha ao obter status"	
	ENDIF
	
	//STAUTS DO PEDIDO
	/*
	IF !Empty(SC7->C7_RESIDUO)
		cRet := "Eliminado Resíduo"
	ELSEIF SC7->C7_ACCPROC <> "1" .And. SC7->C7_CONAPRO == "B" .And. SC7->C7_QUJE < SC7->C7_QUANT
		cRet := "Bloqueado"
	ELSEIF SC7->C7_QUJE == 0 .And. SC7->C7_QTDACLA == 0
		cRet := "Pendente"
	ELSEIF SC7->C7_QUJE <> 0 .And. SC7->C7_QUJE < SC7->C7_QUANT
		cRet := "Parcial"
	ELSEIF SC7->C7_QUJE >= SC7->C7_QUANT
		cRet := "Atendido"
	ENDIF
	*/

RETURN(cRet)
