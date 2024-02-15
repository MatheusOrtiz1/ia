#INCLUDE "PROTHEUS.CH"                   
#INCLUDE "RWMAKE.CH"   
#INCLUDE "XMLXFUN.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CONCOM01  ºAutor  ³EVERTON FORTI       º Data ³  06/06/16   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Realiza a Importacao do XML para realizacao do De Para     º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ TOTVS		 	                                          º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

#define ENTER CHR(13)+CHR(10)

User Function CONCOM01()
	Local cXML, cArq, cMSG
	//Local nO, nC, nPos
	Local cAviso  		:= ""
	Local cErro   		:= ""
	//Local aCONF   		:= {}
	Local _aHead 		:= {"Item","Cod.Prod Fornec","Descrição","Cod.Prod Protheus","Descrição","Quantidade","Vl. Unitario","Vl. Total","NCM"} 
	Local oNF, oDet			
	//Local nUsado 		:= 0 
   	//Local aStruct 		:= {} 
	Local TudoOk	 	:= .F.
	//Local nCntFor 		:= 0 
   	Local aColsAux 		:= {}
   	Local i,ix, x, _nc
   	Private lRefresh	:= .T.
	Private cChvnfe		:= CriaVar("F1_CHVNFE")
	Private cFornec		:= CriaVar("A2_COD")
	Private cDescfor	:= CriaVar("A2_NOME")
	Private cLoja2		:= CriaVar("A2_LOJA")
	Private cEmissao	:= ""
	Private cNotaFis	:= CriaVar("D1_DOC")
	Private cSer		:= CriaVar("D1_SERIE")
	Private cUF			:= "  "
	Private _aCols 		:= {}
		
	//Rotina apenas para opcao de inclusao
	If !Inclui
		Return Nil
	EndIf
	
	//Codigo para que seja possivel realizar o input de informarcoes no aCols
	//--------------------------------------------------
	aNFCab		:= {}
	aNFItem	:= {}
	aItemDec	:= {}
	MV_ALIQISS := SuperGetMV("MV_ALIQISS")
	MV_ESTADO  := SuperGetMV("MV_ESTADO")
	MV_ICMPAD  := SuperGetMV("MV_ICMPAD")
	MV_NORTE   := SuperGetMV("MV_NORTE")
	MV_ESTICM  := SuperGetMV("MV_ESTICM")
	MV_IPIBRUT := SuperGetMV("MV_IPIBRUT")
	MV_SOLBRUT := SuperGetMV("MV_SOLBRUT")
	MV_DSZFSOL := SuperGetMV("MV_DSZFSOL")
	MV_BASERET := SuperGetMV("MV_BASERET")
	MV_GERIMPV := SuperGetMV("MV_GERIMPV")
	MV_FRETEST := SuperGetMV("MV_FRETEST")
	MV_CONTSOC := SuperGetMV("MV_CONTSOC")
	MV_RATDESP := SuperGetMV("MV_RATDESP")
	MV_STREDU  := SuperGetMv("MV_STREDU",,.F.)
	//-------------------------------------------------

	//Carrega os dados do XML para um Objeto na Memoria
	cARQ :=	cGetFile("Arquivo (*.xml) | *.xml", "Selecione o arquivo XML desejado" , 1 , 'C:\',.T.,nOr( GETF_LOCALFLOPPY,GETF_LOCALHARD,GETF_NETWORKDRIVE),.F.,.T.)	
	cXML := Memoread(cArq)	

	IF File(cArq)
		cXML := ""
		FT_FUse(cArq)
		FT_FGotop()   
		While !FT_FEOF()
			cXML += FT_FReadLn()
			FT_FSkip()
		enddo
		FT_FUse()
	endif
	
	oNfe := XmlParser(cXML ,"_",@cAviso,@cErro)    
	
	If valtype(oNFe) != "O"
	   cMSG := "Não foi possivel efetuar a leitura do arquivo XML" + ENTER
	   cMSG += "Nao foi possivel efetuar a Importação do XML"
	   MsgStop(cMSG,"ARQXML")                                
	   Return NIL
	Endif
                                                           '
	oNF := oNFe:_NFeProc:_NFe:_InfNfe  //	       oXml:_NFEPROC:_NFE:_INFNFE:_IDE:_dEmi:Text 
	oDet:= oNF:_Det  
	cCvhnfe	:= SUBSTR(oNFe:_NFEPROC:_NFE:_INFNFE:_ID:TEXT,4,44)
	
	IF CEMPANT == '27' .OR. CEMPANT =='28'
		cFornec	:= SUBSTR(oNF:_EMIT:_CNPJ:TEXT,1,9)
	ELSE	
		cFornec	:= SUBSTR(oNF:_EMIT:_CNPJ:TEXT,1,6)
	ENDIF
		
	cDescfor	:= oNF:_EMIT:_XNOME:TEXT
	
	IF CEMPANT == '27' .OR. CEMPANT =='28'
		cLoja2		:= SUBSTR(oNF:_EMIT:_CNPJ:TEXT,10,3)
	ELSE	
		cLoja2		:= SUBSTR(oNF:_EMIT:_CNPJ:TEXT,10,2)
	ENDIF	
	
	dbselectarea("SA2")
	dbsetorder(3)
	if !dbseek(xFilial()+ALLTRIM(oNF:_EMIT:_CNPJ:TEXT))
		reclock("SA2",.t.)
		SA2->A2_FILIAL := XFILIAL()
		SA2->A2_CGC    := ALLTRIM(oNF:_EMIT:_CNPJ:TEXT)
		SA2->A2_COD    := SUBSTR(oNF:_EMIT:_CNPJ:TEXT,1,9)
		SA2->A2_LOJA   := SUBSTR(oNF:_EMIT:_CNPJ:TEXT,10,3)
		SA2->A2_NOME   := SUBSTR(oNF:_EMIT:_XNOME:TEXT,1,40)
		SA2->A2_NREDUZ := SUBSTR(oNF:_EMIT:_XNOME:TEXT,1,40)
		SA2->A2_INSCR  := ALLTRIM(oNF:_EMIT:_IE:TEXT)
		SA2->A2_CEP    := ALLTRIM(oNF:_EMIT:_ENDEREMIT:_CEP:TEXT)
		SA2->A2_EST    := ALLTRIM(oNF:_EMIT:_ENDEREMIT:_UF:TEXT)
		SA2->A2_MUN    := ALLTRIM(oNF:_EMIT:_ENDEREMIT:_XMUN:TEXT)
		msunlock()
	endif
	cEmissao	:= SubStr((oNF:_IDE:_DHEMI:TEXT),9,2)+"/"+SubStr((oNF:_IDE:_DHEMI:TEXT),6,2)+"/"+SubStr((oNF:_IDE:_DHEMI:TEXT),1,4)
	cNotaFis	:= Padl(AllTrim(oNF:_IDE:_CNF:TEXT),9,'0')//oNF:_IDE:_CNF:TEXT
	cSer		:= Padr(AllTrim(oNF:_IDE:_SERIE:TEXT),3,' ')//oNF:_IDE:_SERIE:TEXT
	cUF			:= oNF:_EMIT:_ENDEREMIT:_UF:TEXT

	DbSelectArea("SF1")
	DbSetOrder(1)
	If DbSeek(xFilial()+cNotaFis+cSer+cFornec+cLoja2)
		cMSG := "Nota Fiscal Proveniente do XML já consta no sistema. O Processo será Abortado!" + ENTER
		cMSG += "Dados da Nota Fiscal: " + ENTER
		cMSG += "Nota Fiscal.: "+cNotaFis+"  Série.:"+cSer+ ENTER
		cMSG += "Fornecedor..: "+cFornec+"  Loja.:"+cLoja2+ ENTER
		cMSG += "Nome/Razão..: "+cDescfor
		MsgInfo(cMSG,"Aviso")                                		
		SF1->(DbCloseArea())
		Return Nil
	EndIf
	SF1->(DbCloseArea())     

	//workaround pra quando for apenas 1 item, DANIEL em 09/06/15
	if valtype(oDet)=="O"
		oDet := {oDet}
	endif	
	
	//Preenche o Array com os itens do XML   1
	For i:=1 to Len(oDet)
		AADD(_aCols,{VerProd(cFornec,cLoja2,oDet[i]:_PROD:_CPROD:TEXT,"1"),;
        POSICIONE("SB1",1,'       '+VerProd(cFornec,cLoja2,oDet[i]:_PROD:_CPROD:TEXT,"1"),"B1_DESC"),;
					  oDet[i]:_PROD:_CPROD:TEXT,;
					  oDet[i]:_PROD:_XPROD:TEXT,;
					  oDet[i]:_PROD:_QCOM:TEXT,;
					  oDet[i]:_PROD:_VUNCOM:TEXT,;
					  oDet[i]:_PROD:_VPROD:TEXT ,;
					  oDet[i]:_PROD:_NCM:TEXT,;
					  Padl(AllTrim(Str(i)),3,'0')})
	Next
	
	SetPrvt("oDlg1","oGrp1","oSay1","oSay2","oSay4","oSay3","oSay5","oSay6","oGet1","oGet2","oGet3","oGet4")
	SetPrvt("oGet6","oGet7","oGrp2","oBtn1","oBtn2","oBtn3","oBrowse")	

	oDlg1      := MSDialog():New( 114,280,710,1242,"Importação XML",,,.F.,,,,,,.T.,,,.T. )
	oGrp1      := TGroup():New( 004,004,080,472,"Dados da Nota Fiscal",oDlg1,CLR_BLACK,CLR_WHITE,.T.,.F. )
	oSay1      := TSay():New( 016,012,{||"Fornecedor"}	,oGrp1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,032,008)
	oSay2      := TSay():New( 032,012,{||"Loja"}			,oGrp1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,032,008)
	oSay4      := TSay():New( 064,012,{||"Número NF"}	,oGrp1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,032,008)
	oSay3      := TSay():New( 048,012,{||"Dt Emissão"}	,oGrp1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,032,008)
	oSay5      := TSay():New( 064,108,{||"Série"}		,oGrp1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,024,008)
	oSay6      := TSay():New( 064,172,{||"UF Orig"}		,oGrp1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,032,008)
	oGet1      := TGet():New( 016,044,{|u| if(PCount()>0,cFornec:=u,cFornec)}	,oGrp1,064,008,'',,CLR_BLACK,CLR_GRAY	,,,,.T.,"",,,.F.,.F.,,.T.,.F.,,"cFornec",,)	 
	oGet2      := TGet():New( 016,112,{|u| if(PCount()>0,cDescfor:=u,cDescfor)}	,oGrp1,204,008,'',,CLR_BLACK,CLR_GRAY	,,,,.T.,"",,,.F.,.F.,,.T.,.F.,,"cDescfor",,)
	oGet3      := TGet():New( 032,044,{|u| if(PCount()>0,cLoja2:=u,cLoja2)}		,oGrp1,036,008,'',,CLR_BLACK,CLR_WHITE	,,,,.T.,"",,,.F.,.F.,,.T.,.F.,,"cLoja2",,)
	oGet4      := TGet():New( 048,044,{|u| if(PCount()>0,cEmissao:=u,cEmissao)}	,oGrp1,060,008,'',,CLR_BLACK,CLR_WHITE	,,,,.T.,"",,,.F.,.F.,,.T.,.F.,,"cEmissao",,)
	oGet5      := TGet():New( 064,044,{|u| if(PCount()>0,cNotaFis:=u,cNotaFis)}	,oGrp1,060,008,'',,CLR_BLACK,CLR_WHITE	,,,,.T.,"",,,.F.,.F.,,.T.,.F.,,"cNotaFis",,)
	oGet6      := TGet():New( 064,136,{|u| if(PCount()>0,cSer:=u,cSer)}			,oGrp1,032,008,'',,CLR_BLACK,CLR_WHITE	,,,,.T.,"",,,.F.,.F.,,.T.,.F.,,"cSer",,)
	oGet7      := TGet():New( 064,204,{|u| if(PCount()>0,cUF:=u,cUF)}				,oGrp1,016,008,'',,CLR_BLACK,CLR_WHITE	,,,,.T.,"",,,.F.,.F.,,.T.,.F.,,"cUF",,)
	oGrp2      := TGroup():New( 080,004,272,472,"Itens da Nota Fiscal",oDlg1,CLR_BLACK,CLR_WHITE,.T.,.F. )
	
	oBrowse	 	:= TWBrowse():New(090,006,463,180,,_aHead,,oGrp2,,,,,{||DeParaPro()},,,,,,,.F.,,.T.,,.F.,,,)   	
	oBrowse:SetArray(_aCols)
	oBrowse:bLine := {|| {_aCols[oBrowse:nAT,9],_aCols[oBrowse:nAT,3],_aCols[oBrowse:nAT,4],_aCols[oBrowse:nAT,1],_aCols[oBrowse:nAT,2],_aCols[oBrowse:nAT,5],_aCols[oBrowse:nAT,6],_aCols[oBrowse:nAT,7],_aCols[oBrowse:nAT,8]}}	//
	
	oBtn1      := TButton():New( 276,200,"&Confirmar",oDlg1,{||TudoOk := (Finaliza())},037,012,,,,.T.,,"",,,,.F. )
	oBtn2      := TButton():New( 276,240,"C&ancelar" ,oDlg1,{||oDlg1:End()},037,012,,,,.T.,,"",,,,.F. )
	oBtn3	   := TButton():New( 276,280,"Pedido"	 ,oDlg1,{|| U_ConsSC7()},037,012,,,,.T.,,"",,,,.F. )	
	
	oDlg1:Activate(,,,.T.)
	
	If TudoOk
		DbSelectArea("SA5")
		DbSetOrder(14) 
		For ix := 1 to Len(_aCols)
			If !Empty(AllTrim(_aCols[ix,1])) 
				If DbSeek(xFilial("SA5")+cFornec+cLoja2+_aCols[ix,3])
					If Empty(AllTrim(SA5->A5_PRODUTO)) 
						RecLock("SA5",.F.)
				 		Replace 	SA5->A5_PRODUTO	With	_aCols[ix,1]
				 		Replace 	SA5->A5_NOMPROD	With	_aCols[ix,2]
						MsUnLock("SA5")
					EndIf
				Else
					RecLock("SA5",.T.)
					SA5->A5_FILIAL	:=	xFilial("SA5")
			 		SA5->A5_FORNECE	:=	cFornec
			 		SA5->A5_LOJA		:=	cLoja2
			 		SA5->A5_NOMEFOR	:=	cDescFor
			 		SA5->A5_PRODUTO	:=	_aCols[ix,1]
			 		SA5->A5_NOMPROD	:=	_aCols[ix,2]
			 		SA5->A5_CODPRF	:=	_aCols[ix,3]
					MsUnLock("SA5")
				EndIf
			EndIf
		Next
		
		//Carrega os dados para tela principal de documento de entrada
		M->CA100FOR 		:= cFornec
		M->CLOJA			:= cLoja2
		M->CNFISCAL			:= cNotaFis
		M->CSERIE			:= cSer
		M->CUFORIG			:= cUF
		M->F1_CHVNFE		:= cCvhnfe    
		M->CESPECIE			:= "SPED"
				
		aColsAux := aClone(aCols)                     
  	   it 		:= 1    
	   nItem	:= 1
	   cItem	:= '0000'   
	   aCols	:={}     
	   nItens	:=0

	   //Carrega os Itens da Nota no Grid
	   For x:= 1 to len(_aCols)      
	       cItem := Soma1(cItem,4)
	       nItens++
	       Aadd(aCols,Array(Len(aHeader)+1))
	       nLenaCols := Len(aCols)
	       Aeval(aHeader, { |e,nX|	If(e[8] == "D", aCols[nLenaCols][nX] := dDataBase,;
										If(e[8] == "N", aCols[nLenaCols][nX] := 0    ,;                                                  
								 		If(e[8] == "C" .And. !Empty(e[1])            ,;
								 		aCols[nLenaCols][nX] := Space(e[4])          ,;
								 		aCols[nLenaCols][nX] := "")))})
								 		
		   aCols[nLenaCols][Len(aCols[1])] := .F.
	      aCols[nLenaCols,1] := cItem    
	      dbselectarea("SB1")
	      dbsetorder(1)
	      if dbseek(xFilial()+_aCols[x,1])
		      _area := getarea()
		      dbselectarea("SB2")
		      dbsetorder(2)//B2_FILIAL+B2_LOCAL+B2_COD
		      if !dbseek(xFilial()+SB1->B1_LOCPAD+SB1->B1_COD)
		      	reclock("SB2",.T.)
		      			SB2->B2_FILIAL := xFilial()
						SB2->B2_COD    := SB1->B1_COD
						SB2->B2_LOCAL  := SB1->B1_LOCPAD
		      	msunlock()
		      endif             
		      restarea(_area)
		      		 
		      GdFieldPut("D1_COD"  	, SB1->B1_COD, nLenaCols)
			  GdFieldPut("D1_LOCAL"  , SB1->B1_LOCPAD	, nLenaCols)
		      GdFieldPut("D1_UM"  		, SB1->B1_UM	, nLenaCols)
		      GdFieldPut("D1_QUANT" 	, Val(_aCols[x,5])	, nLenaCols)
		      GdFieldPut("D1_VUNIT"		, Val(_aCols[x,6])	, nLenaCols) 
		      GdFieldPut("D1_TOTAL" 	, Val(_aCols[x,7])	, nLenaCols)	      
	      endif

	 	next 
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Efetua a carga dos itens digitados do grid para o aCols e sincro ³
		//³niza os novos itens carregando a Matxfis.                        ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		MaFisIni(M->CA100FOR,M->CLOJA,"F","N",Nil,MaFisRelImp("MT100",{"SF1","SD1"}),,.f.,NIL,NIL,NIL)
		MaColsToFis(aHeader,aCols)
		For _nc:=1 To Len(aCols) 
			MaFisRecal(,_nc)  
		    MaFisDel(_nc, aCOLS[_nc][ Len(aCOLS[_nc]) ] )
		Next _nc

		If bRefresh<>Nil
			Eval(bRefresh)
		EndIf

	 	GETDREFRESH()
		SetFocus(oGetDados:oBrowse:hWnd) // Atualizacao por linha
		oGetDados:forceRefresh()
	 	n:= 1		
	EndIf	
Return NIL


//Tela para realizacao do "De Para" dos produtos
Static Function DeParaPro()
	Local oDlg,oBtn,oGrp1,oGrp2
	Local cProdFor	:= CriaVar("A5_CODPRF")
	Local cDescFor	:= CriaVar("A5_DESREF")
	Local cNcmFor		:= "  "
	Private cProduto	:= CriaVar("B1_COD")
	Private cDescri	:= CriaVar("B1_DESC")
	Private cNcm		:= " "
	
	If !Empty(AllTrim(_aCols[oBrowse:nAT,1]))
		Return .T.
	EndIf
	
	cProdFor := _aCols[oBrowse:nAT,3]
	cDescFor := _aCols[oBrowse:nAT,4]
	cNcmFor  := _aCols[oBrowse:nAT,8]
	
	SetPrvt("oDlg2","oGrp1","oSay1","oSay2","oSay3","oGet2","oGet3","oGet1","oGrp2","oSay4","oSay5","oSay6")
	SetPrvt("oGet5","oGet6","oBtn1","oBtn2","oBtn3")
	
	oDlg2      := MSDialog():New( 091,232,347,733,"De Para de Produto",,,.F.,,,,,,.T.,,,.T. )
	oGrp1      := TGroup():New( 004,004,052,240,"De:",oDlg2,CLR_BLACK,CLR_WHITE,.T.,.F. )
	@ 016,008 Say  "Prod Fornec:"	Size 032,008	PIXEL OF oGrp1
	@ 016,048 MsGet cProdFor			Size 076,008	PIXEL OF oGrp1 WHEN .F.
	
	@ 016,132 Say  "NCM:"			Size 020,008	PIXEL OF oGrp1
	@ 016,156 MsGet cNcmFor			Size 068,008	PIXEL OF oGrp1 WHEN .F.
	
	@ 032,008 Say  "Descrição:"		Size 032,008	PIXEL OF oGrp1
	@ 032,048 MsGet cDescFor			Size 176,008	PIXEL OF oGrp1 WHEN .F.

	oGrp2      := TGroup():New( 052,004,100,240,"Para:",oDlg2,CLR_BLACK,CLR_WHITE,.T.,.F. )
	@ 064,008 Say  "Produto:"		Size 032,008	PIXEL OF oGrp2
	@ 064,048 MsGet cProduto			Size 076,008	PIXEL OF oGrp2 VALID DescPro(cProduto) WHEN .T. F3 "SB1"
	
	@ 064,132 Say  "NCM:"			Size 020,008	PIXEL OF oGrp2
	@ 064,156 MsGet cNcm				Size 068,008	PIXEL OF oGrp2 WHEN .F.
	
	@ 080,008 Say  "Descrição:"		Size 032,008	PIXEL OF oGrp2
	@ 080,048 MsGet cDescri			Size 176,008	PIXEL OF oGrp2 WHEN .F.

	oBtn1      := TButton():New( 104,084,"Confirmar",oDlg2,{||GravaProd()},037,012,,,,.T.,,"",,,,.F. )
	oBtn2      := TButton():New( 104,124,"Cancelar"	,oDlg2,{||oDlg2:End()},037,012,,,,.T.,,"",,,,.F. )
	oBtn3	   := TButton():New( 104,164,"Pedido"	,oDlg2,{|| U_ConsSC7()},037,012,,,,.T.,,"",,,,.F. )	
	
	oDlg2:Activate(,,,.T.)
		
Return

//Grava o Produto na Grid 
Static Function GravaProd()	
	If !Empty(AllTrim(cProduto))
		_aCols[oBrowse:nAT,1] := cProduto
		_aCols[oBrowse:nAT,2] := cDescri
		oBrowse:SetArray(_aCols)
		oBrowse:bLine := {|| {_aCols[oBrowse:nAT,9],_aCols[oBrowse:nAT,3],_aCols[oBrowse:nAT,4],_aCols[oBrowse:nAT,1],_aCols[oBrowse:nAT,2],_aCols[oBrowse:nAT,5],_aCols[oBrowse:nAT,6],_aCols[oBrowse:nAT,7],_aCols[oBrowse:nAT,8]}}	//
		oBrowse:Refresh()
	EndIf
	oDlg2:End()	
Return

//Retorna a Descricao e valida o produto 
Static Function DescPro(cProd)
	If !Empty(AllTrim(cProd))
		//Valida se o produto selecionado ja encontrase vinculado a outro produto deste fornecedor	
		DbSelectArea("SA5")
		DbSetOrder(1) 
		If DbSeek(xFilial("SA5")+cFornec+cLoja2+cProd+" ")
			MsgAlert("O Produto ("+AllTrim(cProd)+") selecionado já encontra-se vinculado à outro produto do Fornecedor("+cFornec+") Loja ("+cLoja2+"). Verifique.","Aviso")
			SA5->(DbCloseArea())
			Return .F.
		EndIf
		SA5->(DbCloseArea())
		//Retorna Descricao do produto selecionado
		DbSelectArea("SB1")
		DbSetOrder(1) 
		If !DbSeek(xFilial()+cProd)
			MsgAlert("Produto Não Localizado. Verifique","Aviso")
			SB1->(DbCloseArea())
			Return .F.
		Else	
			cDescri := SB1->B1_DESC
			cNcm	 := SB1->B1_POSIPI
		EndIf
		SB1->(DbCloseArea())
	EndIF
Return .T.
//Apartir do produto do fornecedor, verifica se existe o codigo do produto no protheus
Static Function VerProd(cFornec,cLoja2,cProd)
	Local cRet 		:= ""
	DbSelectArea("SA5")
	DbSetOrder(14) 
	If !DbSeek(xFilial("SA5")+cFornec+cLoja2+cProd+" ")
		cRet :=  "                              "
	Else
		cRet := SA5->A5_PRODUTO
	EndIf
	SA5->(DbCloseArea())
Return cRet
//Validacao
Static Function Finaliza()
	Local lRet := .T.
	oDlg1:End()
Return lRet

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Função para Obtn3 para amarrar o peiddo de compras na nota		³
		//³ 																³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		
User Function ConsSC7(lUsaFiscal,aGets,lNfMedic,lConsMedic,aHeadSDE,aColsSDE,aHeadSEV, aColsSEV, lTxNeg, nTaxaMoeda, aRetPed, oListBox)

Local oDlg,nX
Local cGetPed := Space(6)
Local cItem   := Space(4)
Local oGetPed   
Local aButtons   := { {'PESQUISA',{||A103VisuPC(aRecSC7[oListBox:nAt])},OemToAnsi("Visualiza Pedido"),OemToAnsi("Visualiza Pedido")} } //"Visualiza Pedido"

DEFINE MSDIALOG oDlg TITLE "PEDIDO DE COMPRAS" FROM 0,0 TO 300,500 PIXEL
@ 10,10 SAY "N° Pedido" PIXEL OF oDlg
@ 10,50 MSGET oGetPed VAR cGetPed SIZE 081, 010 OF oDlg F3 "SC7" PIXEL
//aAdd(aButtons, {'PEDIDO',{||A103ForF4( NIL, NIL, lNfMedic, lConsMedic, aHeadSDE, @aColsSDE,aHeadSEV, aColsSEV, @lTxNeg, @nTaxaMoeda),aBackColsSDE:=ACLONE(aColsSDE)},OemToAnsi("STR0024"+" - <F5> "),"Selecionar Pedido de Compra"} ) //"Selecionar Pedido de Compra"
@ 50,50	Button "PEDIDO" Size 35,14 Action A103ForF4( NIL, NIL, lNfMedic, lConsMedic, aHeadSDE, @aColsSDE,aHeadSEV, aColsSEV, @lTxNeg, @nTaxaMoeda) of Odlg Pixel
@ 50,90 Button "Sair"   Size 35,14 Action Close(oDlg) of Odlg Pixel
@ 66,95 BMPBUTTON TYPE 1 ACTION Close(oDlg)
ACTIVATE MSDIALOG oDlg CENTERED

If !Empty(cGetPed)
	If SC7->C7_NUM == cGetPed
		cItem := SC7->C7_NUM
		
		// Gravar o dado no aCols
		// Supondo as posições 50 e 51 como sendo as do Pedido e do Item
		_aCols[oBrowse:nAT,50]  := cGetPed
		_aCols[oBrowse:nAT,51]  := cItem
		
					nPosPC		:= aScan(aHeader,{|x| AllTrim(x[2])=="D1_PEDIDO"})
					nPosItPC  	:= aScan(aHeader,{|x| AllTrim(x[2])=="D1_ITEMPC"})
					
	EndIf
EndIf 

						dbSelectArea("SC7")
						SC7->(dbSetOrder(1))
						For nX := 1 To Len(aCols)
							If !Empty(aCols[nX][nPosPC]) .And. !Empty(aCols[nX][nPosItPC]) .And. aCols[nX][nPosRat] == "1"
								If SC7->(MsSeek(xFilial("SC7")+aCols[nX][nPosPC]+aCols[nX][nPosItPC]))	
									RatPed2NF(aHeadSDE,@aColsSDE,aCols[nX][nPosItNF],SC7->(RecNo()))	
								EndIf
							ElseIf !Empty(aRateioCC) .And. aCols[nX][nPosRat] == "1"
								RatPed2NF(aHeadSDE,@aColsSDE,aCols[nX][nPosItNF],0,aRateioCC)										
							EndIf
						Next nX


      If SC7->(dbSeek(xFilial('SC7')+aCols[n,nPosPc]+aCols[n][nPosItemPC] ))
         If aCols[n][nPosQuant] > ( SC7->C7_QUANT-SC7->C7_QUJE-SC7->C7_QTDACLA)
            Help(" ",1,"QTDLIBMAI")
            lRet := .F.
         EndIf
		EndIf	

Return
