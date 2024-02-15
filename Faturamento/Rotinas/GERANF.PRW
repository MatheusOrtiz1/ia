#INCLUDE "protheus.ch"
#INCLUDE "TOPCONN.CH"

User Function GERANF(_num,_ser)
	Private cLog := ""
	Private lRet := .T.
	Private aPvlNfs := {}
	Private lBlqCrd := .T.
	Private lBlqEst := .T.
	
	dbselectarea("SC5")
	dbsetorder(1)
	dbgotop()
	if dbseek(xFilial()+_num)
		//vai alterar pra tirar os empenhos, se houver
		_ACAB1   := {{"C5_NUM",SC5->C5_NUM,NIL}}
		_AITEPED := {}
		DBSELECTAREA("SC6")
		DBSETORDER(1)
		if DBSEEK(xFilial()+SC5->C5_NUM)
			WHILE !EOF() .AND. SC6->C6_FILIAL+SC6->C6_NUM == cFilAnt+SC5->C5_NUM
				aAux := {}
				aadd(aAux,{"C6_NUM" ,SC6->C6_NUM,NIL})
				aadd(aAux,{"C6_ITEM" ,SC6->C6_ITEM,NIL})
				aadd(aAux,{"C6_PRODUTO" ,SC6->C6_PRODUTO,NIL})
				aadd(aAux,{"C6_TES" ,SC6->C6_TES,NIL})
				aadd(aAux,{"C6_QTDVEN" ,SC6->C6_QTDVEN,NIL})
				aadd(aAux,{"C6_QTDLIB" ,0,NIL})
				aadd(aAux,{"C6_PRCVEN" ,SC6->C6_PRCVEN,NIL})
				aadd(aAux,{"C6_PRUNIT" ,SC6->C6_PRUNIT,NIL})
				aadd(aAux,{"C6_LOCAL" ,SC6->C6_LOCAL,NIL})		
				aadd(aAux,{"C6_CC" ,SC6->C6_CC,NIL})		
				aadd(aAux,{"C6_ITEMCTA" ,SC6->C6_ITEMCTA,NIL})		
				aadd(aAux,{"C6_CLVL" ,SC6->C6_CLVL,NIL})		
				aadd(aAux,{"C6_CONTA" ,SC6->C6_CONTA,NIL})										

				aadd(_AITEPED,aClone(aAux))
				DBSKIP()
			ENDDO

			// ALTERAR PARA RETIRAR O SC9
			LMSERROAUTO := .F.
			LMSHELPAUTO := .F.
			MSEXECAUTO({|X,Y,Z| MATA410(X,Y,Z)},_ACAB1,_AITEPED,4,.F.)
			if LMSERROAUTO
				conout("GERANF - Erro na alteração do pedido.")
				
			else
				conout("GERANF - Alterou o pedido com sucesso.")
			endif

		endif

		dbselectarea("SC6")
		dbsetorder(1)
		dbgotop()
		dbseek(xFilial("SC5")+SC5->C5_NUM)

		while !eof() .and. SC6->C6_FILIAL+SC6->C6_NUM == xFilial("SC5")+SC5->C5_NUM

			MaLibDoFat(SC6->(RecNo()),SC6->C6_QTDVEN,.T.,.T.,.F.,.F.,.F.,.F.)

			dbselectarea("SC6")
			dbskip()
		enddo

		Begin Transaction
			SC6->(MaLiberOk({SC5->C5_NUM},.F.))
		End Transaction

		dbselectarea("SC9")
		dbsetorder(1)
		if dbseek(xfilial()+SC5->C5_NUM)
			while !EOF() .and. SC9->C9_FILIAL == SC5->C5_FILIAL .and. SC9->C9_PEDIDO == SC5->C5_NUM
				if EMPTY(SC9->C9_BLEST) .and. EMPTY(SC9->C9_BLCRED) .and. EMPTY(SC9->C9_BLOQUEI)
					dbselectarea("SC6")
					dbsetorder(1)
					dbSeek(xFilial("SC6")+SC9->C9_PEDIDO+SC9->C9_ITEM)
					dbselectarea("SE4")
					dbsetorder(1)
					dbSeek(xFilial("SE4")+SC5->C5_CONDPAG) //FILIAL+CONDICAO PAGTO
					dbselectarea("SB1")
					dbsetorder(1)
					dbSeek(xFilial("SB1")+SC6->C6_PRODUTO)    //FILIAL+PRODUTO
					dbselectarea("SB2")
					dbsetorder(1)
					dbSeek(xFilial("SB2")+SC6->C6_PRODUTO+SC6->C6_LOCAL) //FILIAL+PRODUTO+LOCAL
					dbselectarea("SF4")
					dbsetorder(1)
					dbSeek(xFilial()+SC6->C6_TES)   //FILIAL+TES
					nPrcVen := SC9->C9_PRCVEN
					Aadd(aPvlNfs,{SC9->C9_PEDIDO,SC9->C9_ITEM,SC9->C9_SEQUEN,SC9->C9_QTDLIB,nPrcVen,SC9->C9_PRODUTO,.f.,SC9->(RecNo()),;
						SC5->(RecNo()),SC6->(RecNo()),SE4->(RecNo()),SB1->(RecNo()),SB2->(RecNo()),SF4->(RecNo())})
				endif
				dbselectarea("SC9")
				dbskip()
			Enddo
		endif

		LMSERROAUTO := .F.
		LMSHELPAUTO := .T.

		if len(aPvlNfs)>0
			CONOUT("VAI RODAR O MaPvlNfs, COM A SERIE "+_ser)
			Pergunte("MT460A",.F.)
			cLog := MaPvlNfs(aPvlNfs,_ser, .F. , .F. , .F. , .F. , .F., 0, 0, .F., .F.)
			conout(" CLOG "+cLog)
			lRet := .T.			
		else
			cLog := "problemas na liberacao dos itens"
			lRet := .F.
		endif

	endif

return {cLog,lRet}
