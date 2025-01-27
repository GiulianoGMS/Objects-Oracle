-- Valida se foi preenchido reducao de PIS ou COFINS na familia, nao deve existir informacao
  -- Ticket 523212
  
  PROCEDURE NAGP_INC_FAM_02       (pnSeqInconsist     in map_incons_familia.seqinconsist%type,
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
               'Familia com Redução de PIS/COFINS indevido!',
               SYSDATE,
               A.DTAHORALTERACAO,
               PSUSUALTERACAO,
               PSTIPOBLOQUEIO
          FROM MAP_FAMILIA     A,
               MAPX_SEQFAMILIA X
         WHERE X.SEQFAMILIA = A.SEQFAMILIA
           AND (NVL(A.PERBASEPIS, 0) > 0 OR NVL(A.PERBASECOFINS, 0) > 0);
        PNINSERIUINCONSIST := SQL%ROWCOUNT;
    EXCEPTION
        WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR(-20200, SQLERRM);
      
   END NAGP_INC_FAM_02;
