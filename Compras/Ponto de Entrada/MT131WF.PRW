#Include "rwmake.ch"

User Function MT131WF()

    cNumCot:= PARAMIXB[1]

    if empty(cNumCot)
        Alert("Nenhuma Cotação foi gerada, verifique preenchimento dos campos!")
    else
        MSGINFO(cNumCot,"Cotacao gerada Numero:" )
    endif

Return Nil
