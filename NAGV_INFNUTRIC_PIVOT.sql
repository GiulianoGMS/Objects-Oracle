CREATE OR REPLACE VIEW CONSINCO.NAGV_INFNUTRIC_PIVOT AS

SELECT * FROM (
SELECT  B.SEQINFNUTRIC, 
        REPLACE(DESCQTDPORCAO,',','.') DESCQTDPORCAO, DESCRICAO
          FROM   MAX_ATRIBUTOFIXO A,
                 MAP_INFNUTRICTAB B
          WHERE  A.SEQATRIBUTOFIXO = B.SEQATRIBUTOFIXO
          AND    A.TIPATRIBUTOFIXO = 'INFNUTRIC'
           )
PIVOT (
    SUM(DESCQTDPORCAO)
    FOR DESCRICAO IN (
        'Fibra Alimentar' FIBRA_ALIMENTAR,
        'Sodio' SODIO,
        'Gorduras Totais' GORDURAS_TOTAIS,
        'Proteinas' PROTEINAS,
        'Carboidratos' CARBOIDRATOS,
        'Gorduras Saturadas' GORDURAS_SATURADAS,
        'Valor Energético' VLR_ENERGETICO,
        'Gorduras Trans' GORDURAS_TRANS,
        'Açúcares Totais' ACURARES_TTOTAIS,
        'Açúcares Adicionados' ACUCARES_ADICIONADOS

    )
);
