-- Adicionada na PKG_INCONSISTENCIAS

PROCEDURE NAGP_INC_FAM_03     (pnSeqInconsist     in map_incons_familia.seqinconsist%type,
                                   psMotivo           in map_incons_familia.motivo%type,
                                   psUsuAlteracao     in ge_usuario.codusuario%type,
                                   psTipoBloqueio     in map_incons_familia.tipobloqueio%type,
                                   pnDiasValidadeNCM  in integer,
                                   pnInseriuInconsist in out number) AS
   
  BEGIN
        INSERT INTO MAP_INCONS_FAMILIA
              (SEQFAMILIA,
               SEQINCONSIST,
               MOTIVO,
               DTAHORGERACAO,
               DTAULTALTERACAO,
               USUALTERACAO,
               TIPOBLOQUEIO)
        SELECT DISTINCT
               A.SEQFAMILIA,
               PNSEQINCONSIST,
              'CST de PIS/COFINS incorretos, verifique!',
               SYSDATE,
               A.DTAHORALTERACAO,
               PSUSUALTERACAO,
               PSTIPOBLOQUEIO
          FROM MAP_FAMILIA     A INNER JOIN MAPX_SEQFAMILIA X ON X.SEQFAMILIA = A.SEQFAMILIA
         WHERE NOT EXISTS (SELECT 1 FROM NAGT_DEPARA_CSTPISCOFINS T WHERE T.ENTRADA = A.SITUACAONFPIS AND T.SAIDA = A.SITUACAONFPISSAI);
                                 
        PNINSERIUINCONSIST := SQL%ROWCOUNT;
    EXCEPTION
        WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR(-20200, SQLERRM);
      
  END NAGP_INC_FAM_03;
