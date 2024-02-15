//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
//±±º  PROGRAMA: SC7XOBS                   		       				        º±±
//±±º     AUTOR: EVERTON FORTI												º±±
//±±º      DATA: 20/03/2022               									º±±
//±±º DESCRIÇÃO: PEDIDO DE COMPRA			    			 		        º±±		   
//±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
User function SC7XOBS()
	Local   aBotoes		:= {}         		//VariÃ¡vel onde serÃ¡ incluido o botÃ£o para a legenda
	Private aACampos  	:= {"C7_PRECO"} 	//VariÃ¡vel contendo o campo editÃ¡vel no Grid
	Private oLista                    		//Declarando o objeto do browser
	Private aCabecalho  := {}         		//Variavel que montarÃ¡ o aHeader do grid
	Private aColsEx 	:= {}        		//VariÃ¡vel que receberÃ¡ os dados
	Private aExp		:= {"C7_PRODUTO","C7_UM","C7_SEGUM","C7_QUANT","C7_CODTAB","C7_PRECO","C7_TOTAL"}
	Private aGArea   	:= getarea()
    Private aGAreaSC7  	:= SC7->(getarea())
	Private oMemo
	Private cMemo		:= ""
	Private cOldMemo	:= ""
	Private	cPedido		:= SC7->C7_NUM
	Private bValid		:= {|| fValid("C7_PRECO")}

	IF SC7->C7_QUJE==0 .And. SC7->C7_QTDACLA==0

		dbselectarea("Z08")
		dbsetorder(1)
		dbseek(xFilial("Z08")+cPedido+"9999")
			dbskip(-1)	

		IF Z08->Z08_NUMPED == cPedido
			cMemo := Z08->Z08_OBS
			cOldMemo := Z08->Z08_OBS
		ENDIF
		

		DEFINE MSDIALOG oDlg TITLE "Desconto Pedido de Compra " + cPedido FROM 000, 000  TO 720, 1280  PIXEL

		//chamar a funçãoS que cria a estrutura do aHeader
		CriaCabec()

		//Monta o browser com inclusão, excluir e atualização
		oLista := MsNewGetDados():New(030, 000, 350, 630,GD_UPDATE, "AllwaysTrue", "AllwaysTrue", "AllwaysTrue", aACampos,0, 999,"AllwaysTrue", "AllwaysTrue", "AllwaysTrue", oDlg, aCabecalho, aColsEx)
		Carregar()
		//Alinho o grid para ocupar todo o meu formulÃ¡rio
		oLista:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT

		//Campo memo
		oMemo   := tMultiget():new( 01, 01, {| u | if( pCount() > 0, cMemo := u, cMemo ) }, ;
			oDlg, 630, 92, , , , , , .T. )

		oMemo:Align := CONTROL_ALIGN_BOTTOM
		//Ao abrir a janela o cursor estao posicionado no meu objeto
		oLista:oBrowse:SetFocus()

		//Crio o menu que ira aparece no botao Acoes relacionadas
		Aadd(aBotoes,{"Banco de Conhecimento",{ || MsDocument('SC7', SC7->(RecNo()), 4) },"Banco de Conhecimento","Banco de Conhecimento"}) 

		EnchoiceBar(oDlg, {|| inGot() }, {|| oDlg:End() },,aBotoes)

		ACTIVATE MSDIALOG oDlg CENTERED
	ELSE
		MSGINFO("Não é possivel alterar o pedido!","Pedido Finalizado")
	ENDIF

restarea(aGArea)
restarea(aGAreaSC7)
Return
Static Function CriaCabec()
	dbSelectArea("SX3")
	SX3->(DbSetOrder(1))
	DbSeek("SC7")
	WHILE !Eof() .AND. (SX3->X3_ARQUIVO=="SC7")
		If X3USO(SX3->X3_USADO) .AND. cNivel>=SX3->X3_NIVEL .AND. SX3->X3_TIPO != "M"
			Aadd(aCabecalho,{ AllTrim(X3Titulo()), ALLTRIM(SX3->X3_CAMPO), SX3->X3_PICTURE,SX3->X3_TAMANHO, SX3->X3_DECIMAL,"Eval(bValid)",SX3->X3_USADO, SX3->X3_TIPO, SX3->X3_F3, SX3->X3_CONTEXT})
		Endif
		SX3->(dbSkip())
	End
	Aadd(aCabecalho,{"Rec", "(RECNO())", "!@",10, 00,".T.","", "C"})
Return

Static Function Carregar()
	Local cCampo	:= ""
	Local nCont		:= 1
	Local aItem		:= {}
	dbSelectArea("SC7")
	SC7->(DbSetOrder(1))
	IF DbSeek(xFilial("SC7") + cPedido)
		WHILE SC7->(!EOF()) .AND. SC7->C7_NUM == cPedido
			aItem	:= {}
			FOR nCont := 1 TO LEN(aCabecalho)
				IF nCont == LEN(aCabecalho)
					aadd(aItem,SC7->(RECNO()))
				ELSE
					cCampo	:= "SC7->" + aCabecalho[nCont][2]
					IF TYPE(cCampo) != "U"
						aadd(aItem,&cCampo)
					ELSE
						aadd(aItem,"")
					ENDIF
				ENDIF
			NEXT nCont
			aadd(aItem,.F.)
			aadd(aColsEx,aItem)
			SC7->(dbSkip())
		ENDDO
	ELSE
		MsgAlert("Não encontrato item para o pedido de compra!", "Desconto Pedido de Compra")
		oDlg:End()
	ENDIF
	//Setar array do aCols do Objeto.
	oLista:SetArray(aColsEx,.T.)
	//Atualizo as informaÃ§Ãµes no grid
	oLista:Refresh()
Return
//C7_NUM
Static Function inGot()
	Local 	i 			:= 1
	Local 	nPoRec		:= aScan(aCabecalho,{|x| Alltrim(x[2]) == "(RECNO())"})
	Local 	nPoVlr		:= aScan(aCabecalho,{|x| Alltrim(x[2]) == "C7_PRECO"})
	Local 	nCont		:= 1
	Local 	cCampo		:= ""
	IF EMPTY(cMemo)
		MsgAlert("Campo observação obrigatório!","Atenção")
		oMemo:SetFocus()
		RETURN
	ELSE
		FOR i := 1 To LEN(oLista:acols)
			dbSelectArea("SC7")
			SC7->(DbSetOrder(1))
			SC7->(DBGoTo(oLista:acols[i][nPoRec]))
			RecLock("SC7", .F.)
			FOR nCont := 1 TO (LEN(aCabecalho)-2)
				cCampo	:= "SC7->" + aCabecalho[nCont][2]
				IF TYPE(cCampo) != "U"
					&cCampo	:= oLista:acols[i][nCont]
				ENDIF
				IF SC7->C7_UVLORIG = 0
					SC7->C7_UVLORIG := aColsEx[i][nPoVlr]
				ENDIF
			NEXT nCont
			MsUnLock()
		NEXT i
		DBSelectArea("Z08")
		Z08->(DbSetOrder(1))
		RecLock("Z08", .T.)
		Z08->Z08_FILIAL	:= XFILIAL("Z08")
		Z08->Z08_NUMPED	:= cPedido
		Z08->Z08_OBS	:= cMemo
		Z08->Z08_SEQ	:= GetSxeNum("Z08","Z08_SEQ")
		MsUnLock()
		oDlg:End()
		MsgInfo("Salvo com Sucesso!","Tudo certo")
		
	ENDIF
return

Static function fValid(coluna)
	Local nLine 	:= oLista:nAt
	Local nCol		:= aScan(aCabecalho,{|x| Alltrim(x[2]) == coluna})
	IF aColsEx[nLine][nCol] >= M->C7_PRECO
		Return .T.
	ELSE
		MsgAlert("Valor digitado é maior que o valor de origem!","Atenção")
		Return .F.
	ENDIF
return
