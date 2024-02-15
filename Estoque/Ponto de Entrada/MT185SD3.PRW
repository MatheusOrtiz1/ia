User Function MT185SD3()

Local UM185D3 := SuperGetMV("MV_UM185D3",.T.,"")

If EMPTY(UM185D3)
    MSGINFO("MV_UM185D3","Para preencher o TM automaticamente preencher o parametro MV_UM185D3!")
ELSE    
    M->D3_TM := UM185D3
ENDIF

CONOUT("***************MT185SD3*****************")
RETURN
    