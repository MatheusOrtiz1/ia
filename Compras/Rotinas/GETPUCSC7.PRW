#include "TOTVS.CH"
#include "TOPCONN.CH"

User Function GETPICSC7() //U_exemplo1()
	Local aBotoes		:= {}         	//Varivel onde ser incluido o boto para a legenda
	Private aACampos  	:= {} 			//Varivel contendo o campo editvel no Grid
	Private oLista                    	//Declarando o objeto do browser
	Private aCabecalho  := {}         	//Variavel que montar o aHeader do grid
	Private aColsEx 	:= {}        	//Varivel que receber os dados
	Private aExp		:= {"C7_NUM    ","C7_EMISSAO","C7_FORNECE","C7_LOJA   ","C7_APROV  ","C7_USER   ","C7_MSFIL  ",}
	Private aGArea   	:= getarea()
	Private aNFE		:= {}
	Private aPergs		:= {}
	Private oBmpOk		:= LoadBitmap(GetResource(), "LBOK")
	Private oBmpNO		:= LoadBitmap(GetResource(), "LBNO")
	Private cVendedor  	:= ""

		DEFINE MSDIALOG oDlg TITLE "Atribui Comprador ao pedido de venda" FROM 000, 000  TO 720, 1280  PIXEL

		//chamar a funo que cria a estrutura do aHeader
		CriaCabec()

		//Monta o browser com incluso, remoo e atualizao
		oLista := MsNewGetDados():New(030, 000, 350, 630,GD_UPDATE, "AllwaysTrue", "AllwaysTrue", "", aACampos, , 999, "AllwaysTrue", "", "AllwaysTrue", oDlg, aCabecalho, aColsEx)
		oLista:oBrowse:BLDBLCLICK := {||CheckField()}
		Carregar()
		//Alinho o grid para ocupar todo o meu formulrio
		oLista:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT

		//Ao abrir a janela o cursor est posicionado no meu objeto
		oLista:oBrowse:SetFocus()

		//Crio o menu que ir aparece no boto Aes relacionadas

		EnchoiceBar(oDlg, {|| inGot() }, {|| oDlg:End() },,aBotoes)

		ACTIVATE MSDIALOG oDlg CENTERED

Return

Static Function CriaCabec()
	Aadd(aCabecalho,{"Selec.", "CHECK", "@BMP",02, 00,".T.","", "C"})
	/*
    For nCont := 1 to len(aExp)
		dbSelectArea("SX3")
		DbSetOrder(1)
		DbSeek("SC7")
		While !Eof().And.(SX3->X3_ARQUIVO=="SC7")
			If cNivel>=SX3->X3_NIVEL .And. aExp[nCont] == alltrim(SX3->X3_CAMPO)
				Aadd(aCabecalho,{ AllTrim(X3Titulo()), ALLTRIM(SX3->X3_CAMPO), SX3->X3_PICTURE,SX3->X3_TAMANHO, SX3->X3_DECIMAL,"AllwaysTrue()",SX3->X3_USADO, SX3->X3_TIPO, SX3->X3_F3, SX3->X3_CONTEXT})
                IF alltrim(SX3->X3_CAMPO) == "C7_LOJA   "
                    Aadd(aCabecalho,{"Nome Fornecedor", "NOME", "!@",10, 00,".T.","", "C"})
                ENDIF
			Endif
			dbSkip()
		End
	Next*/
	Aadd(aCabecalho,{"Pedido", "NUMERO", "!@",04, 00,".T.","", "C"})
	Aadd(aCabecalho,{"Emissão", "EMISSAO", "!@",10, 00,".T.","", "C"})
	Aadd(aCabecalho,{"Fornecedor", "FORNECEDOR", "!@",10, 00,".T.","", "C"})
	Aadd(aCabecalho,{"Loja", "LOJA", "!@",10, 00,".T.","", "C"})
	Aadd(aCabecalho,{"Nome Fornecedor", "NOME", "!@",70, 00,".T.","", "C"})
	Aadd(aCabecalho,{"Grupo Aprov.", "GRUPO", "!@",10, 00,".T.","", "C"})
    Aadd(aCabecalho,{"Usuário", "USER", "!@",10, 00,".T.","", "C"})
	Aadd(aCabecalho,{"Filial", "FILIAL", "!@",10, 00,".T.","", "C"})
	Aadd(aCabecalho,{"Recno.", "RECNO", "!@",10, 00,".T.","", "C"})
Return

Static Function Carregar()
Local CQUERY:=""

    CQUERY := " SELECT DISTINCT(C7_NUM)"
    CQUERY += " FROM "+RetSqlName("SC7") + " SC7"
    //CQUERY += " WHERE C7_QUJE = 0 AND C7_QTDACLA = 0 " //LEGENDA VERDE
    CQUERY += " WHERE C7_CONAPRO = 'B' AND C7_QUJE  < C7_QUANT" //LEGENDA AZUL
    CQUERY += " AND C7_FILIAL = '"+xFilial("SC7")+"'  AND SC7.D_E_L_E_T_ = ' ' AND C7_COMPRA = '   ' "
    CQUERY += " ORDER BY SC7.C7_NUM " 
    IF SELECT("WORKSC7")!=0
        WORKSC7->(DBCLOSEAREA())
    ENDIF
    TCQUERY CQUERY NEW ALIAS "WORKSC7"
    DBSELECTAREA("WORKSC7")
    DBGOTOP()
		
    WHILE WORKSC7->(!Eof())
                
        dbSelectArea("SC7")
        DbSetOrder(1)
        if DbSeek(xFilial("SC7")+WORKSC7->C7_NUM,.T.)

				aadd(aColsEx,{;
					oBmpNO,;
					SC7->C7_NUM,;
					SC7->C7_EMISSAO,;
					SC7->C7_FORNECE,;
					SC7->C7_LOJA,;
					POSICIONE("SA2",1,SC7->C7_MSFIL+SC7->C7_FORNECE+SC7->C7_LOJA,"A2_NOME"),;
					SC7->C7_APROV,;
					SC7->C7_USER,;
					SC7->C7_MSFIL,;
					SC7->(Recno()),;
					.F.;
					})
        ENDIF
        WORKSC7->(dbSkip())
    ENDDO

        if len(aColsEx) == 0 
            MsgInfo("Nenhuma pedido encontrada sem comprador!","Distribui Comprador")
            oLista:End()
	    ENDIF
		//Setar array do aCols do Objeto.
		oLista:SetArray(aColsEx,.T.)

		//Atualizo as informaes no grid
		oLista:Refresh()
Return
Static Function inGot()
	Local	aPergs		:= {}
	Local 	i 			:= 1
	
    aAdd(aPergs, {1, "Comprador", Space(TamSX3("Y1_USER")[1]), "", ".T.", "SY1", ".T.", 80,  .F.})

    /*aAdd(aPergs, {1, "Documento", Space(TamSX3("F1_DOC")[1]), "!@", ".T.","", ".T.", 80,  .F.})
	aAdd(aPergs, {1, "Serie", Space(TamSX3("F1_SERIE")[1]), "!@", ".T.","", ".T.", 80,  .F.})
	aAdd(aPergs, {1, "Data pagamento", Date(),, ".T.","", ".T.", 80,  .F.})
	aAdd(aPergs, {1, "Arquivo Morto", Space(TamSX3("C7_UARQV")[1]), "!@", ".T.","", ".T.", 80,  .F.})*/

	If ParamBox(aPergs, "Selecione o Comprador")
		IF !EMPTY(aColsEx)
			DBSelectArea("SC7")
			SC7->(DbSetOrder(2))
			FOR i := 1 To LEN(oLista:acols)
				IF oLista:acols[i][1] == oBmpOK
					SC7->(DBGoTo(oLista:acols[i][10]))

					WHILE SC7->(!EOF()) .AND. SC7->C7_FILIAL+SC7->C7_NUM == oLista:acols[i][09]+oLista:acols[i][02]
						RecLock("SC7", .F.)
						SC7->C7_COMPRA := MV_PAR01
						MsUnLock()
					SC7->(DBSKIP())
					ENDDO

				ENDIF
			NEXT i
		ENDIF
		oDlg:End()
		MsgInfo("Processo Finalizado!","Amarração Comprador")
		restarea(aGArea)
	ENDIF
Return
Static Function CheckField()
	Local nLine		:= oLista:nAt
	Local nColumn	:= aScan(oLista:aHeader,{|x| x[2] == 'CHECK'})
	Local oCheck	:= oLista:acols[nLine,nColumn]
	If oCheck	== oBmpNO
		oLista:acols[nLine,nColumn] := oBmpOK
	else
		oLista:acols[nLine,nColumn] := oBmpNO
	endif
	oLista:Refresh()
Return
