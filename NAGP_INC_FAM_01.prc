-- Na PKG_INCONSISTENCIAS

PROCEDURE NAGP_INC_FAM_01     (pnSeqInconsist     in map_incons_familia.seqinconsist%type,
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
               v.MSG,
               SYSDATE,
               A.DTAHORALTERACAO,
               PSUSUALTERACAO,
               PSTIPOBLOQUEIO
          FROM MAP_FAMILIA     A INNER JOIN MAPX_SEQFAMILIA X ON X.SEQFAMILIA = A.SEQFAMILIA
                                 INNER JOIN NAGV_VALIDCFOPCGOTRIB_CADFAM V ON V.SEQFAMILIA = A.SEQFAMILIA;
                                 
        PNINSERIUINCONSIST := SQL%ROWCOUNT;
    EXCEPTION
        WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR(-20200, SQLERRM);
      
  END NAGP_INC_FAM_01;
