CREATE OR REPLACE PROCEDURE CONSINCO.NAGP_EXPORTA_SPACEMAN (v_Emp NUMBER) IS

    v_file UTL_FILE.file_type;
    v_line VARCHAR2(32767);
    v_Targetcharset varchar2(40 BYTE);
    v_Dbcharset varchar2(40 BYTE);
    v_Cabecalho VARCHAR2(4000);
    v_LpadLoja  VARCHAR2(3);
    v_Categoria VARCHAR2(200);
    --v_Count NUMBER(10);
    
BEGIN
    
    v_LpadLoja := LPAD(v_Emp,3,0);
    
    FOR t IN (SELECT DISTINCT A.CATEGORIAN3 FROM DIM_CATEGORIA@CONSINCODW A INNER JOIN CONSINCO.NAGT_SPACEMAN_CATEG B ON A.CATEGORIAN3 = B.CATEGORIAN3)
      
    LOOP
    
    v_Categoria := t.Categorian3;
    
    -- Abre o arquivo para escrita
    v_file := UTL_FILE.fopen('/u02/app_acfs/arquivos/Spaceman', v_LpadLoja||'_'||v_Categoria||'_Products'||'.csv', 'w', 32767);
    --v_Dbcharset := 'AMERICAN_AMERICA.AL32UTF8';
    --v_Targetcharset := 'AMERICAN_AMERICA.WE8MSWIN1252';
    
    -- Pega o nome das colunas para inserir no cabecalho
    SELECT LISTAGG(COLUMN_NAME,';') WITHIN GROUP (ORDER BY COLUMN_ID)
     INTO v_Cabecalho
     FROM ALL_TAB_COLUMNS A 
    WHERE A.table_name = 'NAGV_SPACEMAN_DATA';
    
    -- Escreve o cabeçalho do CSV
    UTL_FILE.put_line(v_file, v_Cabecalho);

    -- Executa a query e escreve os resultados
    FOR rec IN (SELECT x.PRODUCT_ID,x.UPC,x.NAME,x.SIZE_VAL,x.UOM,x.MANUFACTURER,x.BRAND,x.CATEGORY,x.SUBCATEGORY,
                       x.SUBSEGMENT,x.DESC_A,x.DESC_B,x.DESC_C,x.DESC_D,x.DESC_E,x.DESC_F,x.DESC_G,x.DESC_H,x.DESC_I,
                       x.DESC_J,x.DESC_K,x.DESC_L,x.HEIGHT,x.WIDTH,x.DEPTHVALUE,x.PRICE,x.COST,x.REG_MOVEMENT,x.CASE_HEIGHT,
                       x.CASE_WIDTH,x.CASE_DEPTH,x.UNITS_CASE,x.FILL_COLOR,x.FILL_PATTERN,x.PACKAGE_TYPE,x.SHAPE_ID,x.TRAY_HEIGHT,
                       x.TRAY_WIDTH,x.TRAY_DEPTH,x.UNITS_CASE_HIGH,x.UNITS_CASE_WIDE,x.UNITS_CASE_DEEP,x.UNITS_TRAY,x.UNITS_TRAY_HIGH,
                       x.UNITS_TRAY_WIDE,x.UNITS_TRAY_DEEP,x.PEG_RIGHT,x.PEG_DOWN,x.PEG_1_RIGHT,x.PEG_1_DOWN,x.PEG_1_DEPTH,x.PEG_2_RIGHT,
                       x.PEG_2_DOWN,x.PEG_3_RIGHT,x.PEG_3_DOWN,x.PEG_NEST,x.VERT_NEST,x.HORIZ_NEST,x.DEPTH_NEST,x.STD_ORIENT,
                       x.BASKET_FACTOR,x.HANG,x.MERCH_STYLE,x.CAP_STYLE,x.DEPTH_FILL,x.STD_PEG,x.STD_PEG_HOLE,x.FIT_TYPE,x.FULL_FACINGS,
                       x.PREFERRED_FIXEL,x.RANK,x.FRONT_0,x.FRONT_90,x.FRONT_180,x.FRONT_270,x.BACK_0,x.BACK_90,x.BACK_180,x.BACK_270,
                       x.LEFT_0,x.LEFT_90,x.LEFT_180,x.LEFT_270,x.RIGHT_0,x.RIGHT_90,x.RIGHT_180,x.RIGHT_270,x.TOP_0,x.TOP_90,
                       x.TOP_180,x.TOP_270,x.BOTTOM_0,x.BOTTOM_90,x.BOTTOM_180,x.BOTTOM_270,x.OVERHANG,x.MAX_VERT_CRUSH,x.MAX_HORIZ_CRUSH,
                       x.MAX_DEPTH_CRUSH,x.DISPLAY_HEIGHT,x.DISPLAY_WIDTH,x.DISPLAY_DEPTH,x.COLOUR,x.COLOURISCLEAR,x.CONTAINHEIGHT,
                       x.CONTAINWIDTH,x.CONTAINDEPTH,x.PEGSPERFACING,x.GTIN,x.USEIMAGEOVERRIDE,x.USEUNITIMAGEFORTRAYSANDCASES,x.IMAGEOVERRIDE,
                       x.MODEL_SCHED,x.MIN_FACINGS,x.MAX_FACINGS,x.TAX_PER,x.TAX_CODE
                       
                  FROM CONSINCO.NAGV_SPACEMAN_DATA X
                 WHERE X.PN = v_Emp
                   AND X.PC = t.Categorian3) 
      
      LOOP
      
        v_line := rec.PRODUCT_ID||';'||rec.UPC||';'||rec.NAME||';'||rec.SIZE_VAL||';'||rec.UOM||';'||rec.MANUFACTURER||';'||rec.BRAND||';'||rec.CATEGORY||';'||rec.SUBCATEGORY||';'
                ||rec.SUBSEGMENT||';'||rec.DESC_A||';'||rec.DESC_B||';'||rec.DESC_C||';'||rec.DESC_D||';'||rec.DESC_E||';'||rec.DESC_F||';'||rec.DESC_G||';'||rec.DESC_H||';'||rec.DESC_I||';'
                ||rec.DESC_J||';'||rec.DESC_K||';'||rec.DESC_L||';'||rec.HEIGHT||';'||rec.WIDTH||';'||rec.DEPTHVALUE||';'||rec.PRICE||';'||rec.COST||';'||rec.REG_MOVEMENT||';'||rec.CASE_HEIGHT||';'
                ||rec.CASE_WIDTH||';'||rec.CASE_DEPTH||';'||rec.UNITS_CASE||';'||rec.FILL_COLOR||';'||rec.FILL_PATTERN||';'||rec.PACKAGE_TYPE||';'||rec.SHAPE_ID||';'||rec.TRAY_HEIGHT||';'
                ||rec.TRAY_WIDTH||';'||rec.TRAY_DEPTH||';'||rec.UNITS_CASE_HIGH||';'||rec.UNITS_CASE_WIDE||';'||rec.UNITS_CASE_DEEP||';'||rec.UNITS_TRAY||';'||rec.UNITS_TRAY_HIGH||';'
                ||rec.UNITS_TRAY_WIDE||';'||rec.UNITS_TRAY_DEEP||';'||rec.PEG_RIGHT||';'||rec.PEG_DOWN||';'||rec.PEG_1_RIGHT||';'||rec.PEG_1_DOWN||';'||rec.PEG_1_DEPTH||';'||rec.PEG_2_RIGHT||';'
                ||rec.PEG_2_DOWN||';'||rec.PEG_3_RIGHT||';'||rec.PEG_3_DOWN||';'||rec.PEG_NEST||';'||rec.VERT_NEST||';'||rec.HORIZ_NEST||';'||rec.DEPTH_NEST||';'||rec.STD_ORIENT||';'
                ||rec.BASKET_FACTOR||';'||rec.HANG||';'||rec.MERCH_STYLE||';'||rec.CAP_STYLE||';'||rec.DEPTH_FILL||';'||rec.STD_PEG||';'||rec.STD_PEG_HOLE||';'||rec.FIT_TYPE||';'||rec.FULL_FACINGS||';'
                ||rec.PREFERRED_FIXEL||';'||rec.RANK||';'||rec.FRONT_0||';'||rec.FRONT_90||';'||rec.FRONT_180||';'||rec.FRONT_270||';'||rec.BACK_0||';'||rec.BACK_90||';'||rec.BACK_180||';'||rec.BACK_270||';'
                ||rec.LEFT_0||';'||rec.LEFT_90||';'||rec.LEFT_180||';'||rec.LEFT_270||';'||rec.RIGHT_0||';'||rec.RIGHT_90||';'||rec.RIGHT_180||';'||rec.RIGHT_270||';'||rec.TOP_0||';'||rec.TOP_90||';'
                ||rec.TOP_180||';'||rec.TOP_270||';'||rec.BOTTOM_0||';'||rec.BOTTOM_90||';'||rec.BOTTOM_180||';'||rec.BOTTOM_270||';'||rec.OVERHANG||';'||rec.MAX_VERT_CRUSH||';'||rec.MAX_HORIZ_CRUSH||';'
                ||rec.MAX_DEPTH_CRUSH||';'||rec.DISPLAY_HEIGHT||';'||rec.DISPLAY_WIDTH||';'||rec.DISPLAY_DEPTH||';'||rec.COLOUR||';'||rec.COLOURISCLEAR||';'||rec.CONTAINHEIGHT||';'
                ||rec.CONTAINWIDTH||';'||rec.CONTAINDEPTH||';'||rec.PEGSPERFACING||';'||rec.GTIN||';'||rec.USEIMAGEOVERRIDE||';'||rec.USEUNITIMAGEFORTRAYSANDCASES||';'||rec.IMAGEOVERRIDE||';'
                ||rec.MODEL_SCHED||';'||rec.MIN_FACINGS||';'||rec.MAX_FACINGS||';'||rec.TAX_PER||';'||rec.TAX_CODE;
                
        UTL_FILE.put_line(v_file, v_line);
    END LOOP;

    -- Fecha o arquivo
    UTL_FILE.fclose(v_file);
    
    END LOOP;
    
EXCEPTION
  
    WHEN OTHERS THEN
        IF UTL_FILE.is_open(v_file) THEN
            UTL_FILE.fclose(v_file);
        END IF;
        RAISE;
        
        
END;
