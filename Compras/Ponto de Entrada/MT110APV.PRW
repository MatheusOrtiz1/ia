
//-------------------------------------------------------------------------
//Programa: MT110APV        Autor: Everton Forti        Data:22/07/2022   |
//-------------------------------------------------------------------------
//Ponto de entrada para validar Aprova��o de Solicita��o de Compra        |
//Permiti aprovar somente usu�rios que est�o cadastrados como Aprovadores |
//-------------------------------------------------------------------------
User Function MT110APV()
//Local cParam1:=ParamIxb[1]
//Local nParam2:=ParamIxb[2]
Local lRet:=.F.// Valida��es //
lOCAL cUserId   := RetCodUsr()
Local lAtiva := SUPERGETMV("MV_UAPVSOL",.F.,.F.) //ATIVA CONTROLE AL�ADAS

    IF lAtiva
        dbSelectArea('SAK')//APROVADORES
        dbSetOrder(2)
        IF dbSeek(xFilial('SAK')+cUserId)
            lRet:=.T.
        ELSE
            MSGINFO("Usu�rio sem acesso ao controle de Al�adas para libear solicita��o!","MT110APV")
        ENDIF
    ELSE
        lRet:=.T.
    ENDIF

Return lRet
