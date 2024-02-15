#include "TOTVS.CH"
#include "TOPCONN.CH"

User Function GETSC1COM() //U_exemplo1()
	Local aBotoes		:= {}         	//Varivel onde ser incluido o boto para a legenda
	Private aACampos  	:= {} 			//Varivel contendo o campo editvel no Grid
	Private oLista                    	//Declarando o objeto do browser
	Private aCabecalho  := {}         	//Variavel que montar o aHeader do grid
	Private aColsEx 	:= {}        	//Varivel que receber os dados
	Private aExp		:= {"C1_NUM    ","C1_EMISSAO","C1_FORNECE","C1_LOJA   ","C1_UGRUPO ","C1_SOLICIT   ","C1_MSFIL  ",}
	Private aGArea   	:= getarea()
	Private aNFE		:= {}
	Private aPergs		:= {}
	Private oBmpOk		:= LoadBitmap(GetResource(), "LBOK")
	Private oBmpNO		:= LoadBitmap(GetResource(), "LBNO")
	Private cVendedor  	:= ""

		DEFINE MSDIALOG oDlg TITLE "Atribui Comprador na solicitação de compra" FROM 000, 000  TO 720, 1280  PIXEL

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
		DbSeek("SC1")
		While !Eof().And.(SX3->X3_ARQUIVO=="SC1")
			If cNivel>=SX3->X3_NIVEL .And. aExp[nCont] == alltrim(SX3->X3_CAMPO)
				Aadd(aCabecalho,{ AllTrim(X3Titulo()), ALLTRIM(SX3->X3_CAMPO), SX3->X3_PICTURE,SX3->X3_TAMANHO, SX3->X3_DECIMAL,"AllwaysTrue()",SX3->X3_USADO, SX3->X3_TIPO, SX3->X3_F3, SX3->X3_CONTEXT})
                IF alltrim(SX3->X3_CAMPO) == "C1_LOJA   "
                    Aadd(aCabecalho,{"Nome Fornecedor", "NOME", "!@",10, 00,".T.","", "C"})
                ENDIF
			Endif
			dbSkip()
		End
	Next*/
	Aadd(aCabecalho,{"Solicitacao", "NUMERO", "!@",04, 00,".T.","", "C"})
	Aadd(aCabecalho,{"Emissão", "EMISSAO", "!@",10, 00,".T.","", "C"})
	Aadd(aCabecalho,{"Fornecedor", "FORNECEDOR", "!@",10, 00,".T.","", "C"})
	Aadd(aCabecalho,{"Loja", "LOJA", "!@",10, 00,".T.","", "C"})
	Aadd(aCabecalho,{"Nome Fornecedor", "NOME", "!@",70, 00,".T.","", "C"})
	Aadd(aCabecalho,{"Grupo Aprov.", "GRUPO", "!@",10, 00,".T.","", "C"})
    Aadd(aCabecalho,{"Solicitante", "USER", "!@",10, 00,".T.","", "C"})
	Aadd(aCabecalho,{"Filial", "FILIAL", "!@",10, 00,".T.","", "C"})
	Aadd(aCabecalho,{"Recno.", "RECNO", "!@",10, 00,".T.","", "C"})
Return

Static Function Carregar()
Local CQUERY:=""

    CQUERY := " SELECT DISTINCT(C1_NUM)"
    CQUERY += " FROM "+RetSqlName("SC1") + " SC1"
	CQUERY += " WHERE C1_CODCOMP = '   ' " //COMENTE SEM COMPRADOR
    CQUERY += " AND C1_QUJE = 0 AND C1_COTACAO = '      ' AND C1_RESIDUO = '' " // Verde SC Pendente
    //CQUERY += C1_QUJE > 0 .AND. EMPTY(C1_PEDIDO) .AND. EMPTY(C1_RESIDUO) //Amarela Parcialmente atendida 
    //CQUERY += C1_TPSC != "2" .And. C1_QUJE == 0 .And. C1_COTACAO <> Space(Len(C1_COTACAO)) .And. C1_IMPORT <>"S" //SC EM COTAÇÃO:
    CQUERY += " AND C1_FILIAL = '"+xFilial("SC1")+"'  AND SC1.D_E_L_E_T_ = ' ' AND C1_APROV LIKE '% %'  "
    CQUERY += " ORDER BY SC1.C1_NUM " 
    IF SELECT("WORKSC1")!=0
        WORKSC1->(DBCLOSEAREA())
    ENDIF
    TCQUERY CQUERY NEW ALIAS "WORKSC1"
    DBSELECTAREA("WORKSC1")
    DBGOTOP()
		
    WHILE WORKSC1->(!Eof())
                
        dbSelectArea("SC1")
        DbSetOrder(1)
        if DbSeek(xFilial("SC1")+WORKSC1->C1_NUM,.T.)

				aadd(aColsEx,{;
					oBmpNO,;
					SC1->C1_NUM,;
					SC1->C1_EMISSAO,;
					SC1->C1_FORNECE,;
					SC1->C1_LOJA,;
					POSICIONE("SA2",1,SC1->C1_MSFIL+SC1->C1_FORNECE+SC1->C1_LOJA,"A2_NOME"),;
					SC1->C1_UGRUPO,; 
					SC1->C1_SOLICIT,;
					SC1->C1_MSFIL,;
					SC1->(Recno()),;
					.F.;
					})
        ENDIF
        WORKSC1->(dbSkip())
    ENDDO

        if len(aColsEx) == 0 
            MsgInfo("Nenhuma solicitação encontrada sem comprador!","Distribui Comprador")
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
	aAdd(aPergs, {1, "Arquivo Morto", Space(TamSX3("C1_UARQV")[1]), "!@", ".T.","", ".T.", 80,  .F.})*/

	If ParamBox(aPergs, "Selecione o Comprador")
		IF !EMPTY(aColsEx)
			DBSelectArea("SC1")
			SC1->(DbSetOrder(2))
			FOR i := 1 To LEN(oLista:acols)
				IF oLista:acols[i][1] == oBmpOK
					SC1->(DBGoTo(oLista:acols[i][10]))

					WHILE SC1->(!EOF()) .AND. SC1->C1_FILIAL+SC1->C1_NUM == oLista:acols[i][09]+oLista:acols[i][02]
						RecLock("SC1", .F.)
						SC1->C1_CODCOMP := MV_PAR01
						MsUnLock()
					SC1->(DBSKIP())
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
