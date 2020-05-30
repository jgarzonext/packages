--------------------------------------------------------
--  DDL for Package Body PAC_CARGAS_MSV
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_CARGAS_MSV" IS
   /******************************************************************************
      NOMBRE:      PAC_CARGAS_MSV
      PROPÓSITO: Funciones para la gestión de la carga de procesos
      REVISIONES:
      Ver        Fecha        Autor             Descripción
      ---------  ----------  ---------------  ------------------------------------
      1.0        17/09/2013   FAL              1. Creación del package.
   ******************************************************************************/


/*************************************************************************
         Procedimiento que guarda logs en las diferentes tablas.
   param p_tabobj in : tab_error tobjeto
   param p_tabtra in : tab_error ntraza
   param p_tabdes in : tab_error tdescrip
   param p_taberr in : tab_error terror
   param p_propro in : PROCESOSLIN sproces
   param p_protxt in : PROCESOSLIN tprolin
   devuelve número o null si existe error.
*************************************************************************/
PROCEDURE p_genera_logs(
        p_tabobj IN VARCHAR2,
        p_tabtra IN NUMBER,
        p_tabdes IN VARCHAR2,
        p_taberr IN VARCHAR2,
        p_propro IN NUMBER,
        p_protxt IN VARCHAR2) IS
      
        vnnumlin       NUMBER;
        vnum_err       NUMBER;
   
    BEGIN
    
        IF p_tabobj IS NOT NULL AND p_tabtra IS NOT NULL THEN
            p_tab_error(f_sysdate, f_user, p_tabobj, p_tabtra, SUBSTR(p_tabdes, 1, 500), SUBSTR(p_taberr, 1, 2500));
        END IF;

        IF p_propro IS NOT NULL AND p_protxt IS NOT NULL THEN
            vnnumlin := NULL;
            vnum_err := f_proceslin(p_propro, SUBSTR(p_protxt, 1, 120), 1, vnnumlin);
        END IF;
        
END p_genera_logs;

   /*************************************************************************
                Función que marca linea que tratamos con un estado.
          param p_pro in : proceso
          param p_lin in : linea
          param p_tip in : tipo
          param p_est in : estado
          param p_val in : validado
          param p_seg in : seguro
          devuelve número o null si existe error.
      *************************************************************************/
   FUNCTION p_marcalinea(
      p_pro IN NUMBER,
      p_lin IN NUMBER,
      p_tip IN VARCHAR2,
      p_est IN NUMBER,
      p_val IN NUMBER,
      p_seg IN NUMBER,
      p_id_ext IN VARCHAR2,
      p_ncarg IN NUMBER,
      p_sin IN NUMBER DEFAULT NULL,
      p_tra IN NUMBER DEFAULT NULL,
      p_per IN NUMBER DEFAULT NULL,
      p_rec IN NUMBER DEFAULT NULL)
      RETURN NUMBER IS
      vobj           VARCHAR2(100) := 'PAC_CARGAS_MSV.P_MARCALINEA';
      num_err        NUMBER;
      vtipo          NUMBER;
      num_lin        NUMBER;
      num_aux        NUMBER;
      
   BEGIN
      
      IF p_tip = 'ALTA' THEN
         vtipo := 0;
      ELSIF p_tip = 'ALTA_REC' OR p_tip = 'MODI_REC' THEN
         vtipo := 2;
      ELSIF p_tip = 'PER' then 
         vtipo :=3;  
      ELSE
         vtipo := 0;
      END IF;

      num_err :=
         pac_gestion_procesos.f_set_carga_ctrl_linea
            (p_pro, p_lin, vtipo, p_lin, p_tip, p_est, p_val, p_seg,   -- Bug 14888. FAL. 13/10/2010. Añadir id. externo (npoliza,nsinies,nrecibo) de la compañia
             p_id_ext,   -- Fi Bug 14888
                         -- Bug 16324. FAL. 26/10/2010. Añadir ncarga (relacion con tablas mig)
             p_ncarg,   -- Fi Bug 16324
             p_sin, p_tra, p_per, p_rec);

      IF num_err <> 0 THEN   --Si fallan estas funciones de gestión salimos del programa
         p_genera_logs(vobj, 1, num_err,
                       'p=' || p_pro || ' l=' || p_lin || ' t=' || p_tip || ' EST=' || p_est
                       || ' v=' || p_val || ' s=' || p_seg,
                       p_pro, 'Error ' || num_err || ' l=' || p_lin || ' e=' || p_est);
         num_err := 1;
      END IF;

      RETURN num_err;
   END p_marcalinea;

   /*************************************************************************
                    Función que marca el error de la linea que tratamos.
          param p_pro in : proceso
          param p_lin in : linea
          param p_ner in : numero error
          param p_tip in : tipo
          param p_cod in : codigo
          param p_men in : mensaje
          devuelve número o null si existe error.
      *************************************************************************/
   FUNCTION p_marcalineaerror(
      p_pro IN NUMBER,
      p_lin IN NUMBER,
      p_ner IN NUMBER,
      p_tip IN NUMBER,
      p_cod IN NUMBER,
      p_men IN VARCHAR2)
      RETURN NUMBER IS
      vobj           VARCHAR2(100) := 'PAC_CARGAS_MSV.P_MARCALINEAERROR';
      num_err        NUMBER;
   BEGIN
      num_err := pac_gestion_procesos.f_set_carga_ctrl_linea_error(p_pro, p_lin, p_ner, p_tip,
                                                                   p_cod, p_men);

      IF num_err <> 0 THEN   --Si fallan estas funciones de gestión salimos del programa
         p_genera_logs(vobj, 1, num_err,
                       'p=' || p_pro || ' l=' || p_lin || ' n=' || p_ner || ' t=' || p_tip
                       || ' c=' || p_cod || ' m=' || p_men,
                       p_pro, 'Error ' || num_err || ' l=' || p_lin || ' c=' || p_cod);
         num_err := 1;
      END IF;

      RETURN num_err;
   END p_marcalineaerror;


FUNCTION f_censo_ejecutarcarga(
        p_nombre IN VARCHAR2,
        p_path IN VARCHAR2,
        p_cproces IN NUMBER,
        psproces IN OUT NUMBER) 
        RETURN NUMBER IS
     
        vobj   VARCHAR2(100) := 'PAC_CARGAS_MSV.F_CENSO_EJECUTARCARGA';
        vtraza   NUMBER := 0;
        vnum_err   NUMBER;
        vsalir   EXCEPTION;
        wlinerr   NUMBER := 0;
   
    BEGIN
  
        vtraza := 0;
      
        SELECT NVL(cpara_error, 0) INTO k_para_carga
        FROM cfg_files
        WHERE cempres = k_empresaaxis
        AND cproceso = p_cproces;
                     
        IF psproces IS NULL THEN
            
            vnum_err := f_censo_ejecutarcargafichero(p_nombre, p_path, p_cproces, psproces);
                     
            IF vnum_err <> 0 THEN
                RAISE vsalir;
            END IF;
            
        END IF;
                     
        vtraza := 1;
        vnum_err := f_censo_ejecutarcargaproceso(psproces); --Posibles retornos: 1- Error, 2correcto , 3- pendiente, 4 con avisos
                       
        UPDATE int_carga_ctrl 
           SET cestado = vnum_err, 
               ffin = f_sysdate
         WHERE sproces = psproces;
                     
        COMMIT;                     
       
        RETURN 0;
        
            EXCEPTION
            WHEN vsalir THEN
            RETURN 1;
            
END f_censo_ejecutarcarga;

/***************************************************************************
        FUNCTION f_next_carga
        Asigna número de carga
        return : Número de carga
***************************************************************************/
FUNCTION f_next_carga
  RETURN NUMBER IS
  v_seq          NUMBER;
BEGIN
  SELECT sncarga.NEXTVAL
    INTO v_seq
    FROM DUAL;

  RETURN v_seq;
END f_next_carga;

FUNCTION f_alta_censo(
      x IN OUT INT_CARGA_CENSOMALTA%ROWTYPE,
      p_deserror IN OUT VARCHAR2,
      psinterf OUT int_mensajes.sinterf%TYPE,
      p_ssproces IN NUMBER)
      RETURN NUMBER IS
      
        vobj           VARCHAR2(100) := 'PAC_CARGAS_MSV.F_ALTA_CENSO';
        v_ncarga       NUMBER;
        v_seq          NUMBER;
        errdatos       EXCEPTION;
        
        v_mig_personas MIG_PERSONAS%ROWTYPE;
        v_id           VARCHAR2(8);
        verror         VARCHAR2(1000);
        cerror         VARCHAR2(1000);
        vtraza         NUMBER;
        v_tdeserror    VARCHAR2(1000);
        v_nnumerr      NUMBER;
  
BEGIN 
    
    BEGIN
    
        v_id := x.dni;
        
        vtraza := 1;  
        v_ncarga := f_next_carga;
                
        vtraza := 10;
        IF v_id IS NULL THEN
            verror := 'El identificador de persona no puede ser nulo';
            cerror := 10000;
            RAISE errdatos;
        END IF;
        
        vtraza := 20;
        INSERT INTO mig_cargas
                      (ncarga, cempres, finiorg, ffinorg, ID, estorg)
               VALUES (v_ncarga, k_empresaaxis, f_sysdate, f_sysdate, v_id, 'OK');
        
        vtraza := 30;
        INSERT INTO mig_cargas_tab_mig
                      (ncarga, tab_org, tab_des, ntab)
               VALUES (v_ncarga, 'INT_CARGA_CENSOMALTA', 'MIG_PERSONAS', 0);
                    
        vtraza := 50;
        v_mig_personas.ncarga := v_ncarga;
        vtraza := 51;
        v_mig_personas.cestmig := 1;
        vtraza := 52;
        v_mig_personas.mig_pk := v_ncarga || '/' || x.DNI;
        vtraza := 53;
        v_mig_personas.idperson := 0;
        vtraza := 54;
        v_mig_personas.snip := NULL;
        vtraza := 55;
        v_mig_personas.ctipide := 2;
        vtraza := 56;
        v_mig_personas.nnumide := x.dni;
        vtraza := 57;
        v_mig_personas.cestper := 0;
        vtraza := 58;
        v_mig_personas.cpertip := 1;
        vtraza := 59;
        v_mig_personas.swpubli := 0;
        vtraza := 60;
        v_mig_personas.csexper := NULL;
        vtraza := 61;
        v_mig_personas.fnacimi := NULL;
        vtraza := 62;
        v_mig_personas.cagente := 19000;      
        vtraza := 63;
        v_mig_personas.tapelli1 := x.apellidos;
        vtraza := 64;
        v_mig_personas.tapelli2 := NULL;
        vtraza := 65;
        v_mig_personas.tnombre := x.nombre;
        vtraza := 66;
        v_mig_personas.ctipdir := 1;
        vtraza := 67;
        v_mig_personas.tnomvia := SUBSTR(x.calle,1,40);
        vtraza := 68;
        v_mig_personas.ctipvia := 9; --Calle        
        vtraza := 69;
        v_mig_personas.nnumvia := NULL;
        vtraza := 70;
        v_mig_personas.tcomple := NULL;
        vtraza := 71;
        v_mig_personas.cpais :=  pac_parametros.f_parinstalacion_n('PAIS_DEF');
        vtraza := 72;
        v_mig_personas.cnacio := pac_parametros.f_parinstalacion_n('PAIS_DEF');
        vtraza := 73;
        v_mig_personas.cpostal := NULL;
        vtraza := 74;
        v_mig_personas.cprovin := x.cprovin;
        vtraza := 75;
        v_mig_personas.cpoblac := x.cpoblac;
        vtraza := 76;
        v_mig_personas.cidioma := 5;
        vtraza := 77;
        v_mig_personas.tnumtel := NULL;
        vtraza := 78;
        v_mig_personas.tnummov := NULL;
            
        vtraza := 80;
        INSERT INTO mig_personas VALUES v_mig_personas;
        
        vtraza := 90;  
        INSERT INTO mig_pk_emp_mig
           VALUES (0, v_ncarga, 0, v_mig_personas.mig_pk);
                        
        vtraza := 100;
        pac_mig_axis.p_migra_cargas(v_id, 'C', v_ncarga, 'DEL');
              
        COMMIT;
        
        RETURN 0;
        
    EXCEPTION        
        WHEN OTHERS THEN
            
            v_nnumerr := SQLCODE;
            v_tdeserror := SQLCODE || ' ' || SQLERRM;
                       
            p_genera_logs(vobj, vtraza, 'Error ' || v_nnumerr, SQLERRM, p_ssproces,
                                        'Error ' || v_tdeserror);        
        RETURN v_nnumerr;    
    END;
        
END f_alta_censo; 

 
FUNCTION f_censo_ejecutarcargafichero (
        p_nombre IN VARCHAR2,
        p_path IN VARCHAR2,
        p_cproces IN NUMBER,
        psproces   OUT NUMBER)
        RETURN NUMBER IS
        
        vdeserror   VARCHAR2(1000);
        vobj        VARCHAR2(100) := 'PAC_CARGAS_MSV.F_CENSO_EJECUTARCARGAFICHERO';        
        linea       NUMBER := 0;        
        vtraza      NUMBER := 0;        
        vnum_err    NUMBER := 0;
        pcarga      NUMBER;
        vtiperr     NUMBER;
        vcoderror   NUMBER;                
        errorini    EXCEPTION;
        e_errdatos  EXCEPTION;
        vsalir      EXCEPTION;
        verrorfin   BOOLEAN := FALSE;
        vavisfin    BOOLEAN := FALSE;
        v_deserror  INT_CARGA_CTRL_LINEA_ERRS.tmensaje%TYPE;    
        v_tfichero  INT_CARGA_CTRL.tfichero%TYPE;
                
        v_line        VARCHAR2(32000);        
        v_file        UTL_FILE.FILE_TYPE;     
        v_numlineaF   NUMBER; --numlinea del fichero
        v_numlineaI   NUMBER; --numlinea del insert 
        v_nombre      VARCHAR2(160);
        v_apellidos   VARCHAR2(160);
        v_nombresol   VARCHAR2(160);
        v_direccion   VARCHAR2 (160);  
        v_dni         VARCHAR2(8);
        v_calle       VARCHAR2(160);
        v_details     VARCHAR2(92);        
        v_councilcode NUMBER(3);
        v_councilname VARCHAR2(160);
        v_eslineaper  BOOLEAN := FALSE;
        v_votante     NUMBER(1);
        v_poblac      POBLACIONES_REL_MSV.CPOBLAC%TYPE;
        v_provin      POBLACIONES_REL_MSV.CPROVIN%TYPE;  
        wsinterf      INT_MENSAJES.SINTERF%TYPE;
        
    BEGIN
    
        vtraza := 0;
         
        SELECT sproces.NEXTVAL INTO psproces
          FROM DUAL;
         
        vtraza := 1;         
        IF p_cproces IS NULL THEN
            vnum_err := 9901092;
            vdeserror := 'cfg_files falta proceso: ' || vobj;
            RAISE e_errdatos;
        END IF;
         
        vtraza := 2;
        vnum_err := pac_gestion_procesos.f_set_carga_ctrl_cabecera(psproces, p_nombre, f_sysdate, NULL, 3, p_cproces, NULL, NULL);
        vtraza := 3;
         
        IF vnum_err <> 0 THEN   p_tab_error(f_sysdate, f_user, vobj, vtraza, vnum_err, 'Error llamando a pac_gestion_procesos.f_set_carga_ctrl_cabecera');
            RAISE errorini; --Error que para ejecución
        END IF;
         
        vtraza := 4;
        -- Abrimos fichero
        v_file := UTL_FILE.FOPEN(p_path ,p_nombre, 'r');
        v_numlineaF := 1;
        v_numlineaI := 1; 
        vtraza := 5;
        
        -- Leeemos el fichero
        LOOP
        
          BEGIN
            
            --Obtenemos cada linea
            vtraza := 6;
            UTL_FILE.GET_LINE(v_file, v_line);
                         
            IF v_numlineaF = 1 THEN 
                v_councilcode := TO_NUMBER(SUBSTR(v_line,1, 3));
                v_councilname := SUBSTR(v_line, 6);
                                
                BEGIN
                    
                    --Sacamos la poblacion que nos pasa MSV por fichero y la buscamos en nuestra tabla de relacion (poblaciones iAxis vs MSV) 
                    SELECT cpoblac, cprovin INTO v_poblac, v_provin
                      FROM poblaciones_rel_msv 
                     WHERE cpoblac_msv = v_councilcode;
                     
                EXCEPTION
                   -- No hemos encontrado la poblacion 
                   WHEN NO_DATA_FOUND THEN 
                       NULL;
                       --Añadimos traza de error??  
                    WHEN OTHERS THEN
                       EXIT;                 
                END;
                                       
                
            END IF;                        
                         
            vtraza := 7;
            IF SUBSTR(v_line, 1, 1) = ' ' THEN
                
                --Persona (NO nuevo votante)
                vtraza := 8;                    
                v_eslineaper := TRUE;
                v_votante := 0;
            
            ELSIF SUBSTR(v_line, 1, 1) = '*' THEN
                
                --Persona (SI nuevo votante)
                vtraza := 9;                    
                v_eslineaper := TRUE;
                v_votante := 1;
            
            ELSIF SUBSTR(v_line, 1, 1) != ' ' AND  v_numlineaF > 2 THEN

                --Es una dirección 
                vtraza := 10;
                v_direccion := SUBSTR(v_line,1, 160);
                v_votante := NULL;
                v_eslineaper := FALSE;                
                            
            ELSE
                
                vtraza := 11;
                v_votante := NULL;
                v_eslineaper := FALSE;               
                        
            END IF;
                        
            vtraza := 12;
            IF v_eslineaper THEN
                
                vtraza := 13;
                                
                --Tratamiento para el nombre y apellidos
                v_nombre := SUBSTR(v_line,3, 160);
                v_nombre := LTRIM(RTRIM(v_nombre));
                v_nombre := SUBSTR(v_nombre,INSTR(v_nombre,' ',-1));
                
                --En algunos casos deberemos limpiar la coma del final
                v_nombre := REPLACE(v_nombre, ',', '');
                                
                v_apellidos := SUBSTR(v_line,3, 160);
                v_apellidos := LTRIM(RTRIM(v_apellidos));
                v_apellidos := SUBSTR(v_apellidos,1,INSTR(v_apellidos,' ',-1));
                                
                v_nombresol := SUBSTR(v_line ,163, 160);                                
                v_details := SUBSTR(v_line, 323, 92);      
                v_dni :=  SUBSTR(v_line, 415, 8);
                
            END IF;
                         
          EXCEPTION  
            WHEN NO_DATA_FOUND THEN 
                EXIT;  
            WHEN OTHERS THEN 
            
                --Si hay un error leyendo el fichero salimos del programa del todo y lo indicamos.
                vtraza := 14;
                vnum_err := pac_gestion_procesos.f_set_carga_ctrl_cabecera(psproces, p_nombre, f_sysdate, NULL, 1, p_cproces, NULL, vdeserror);
                
                vtraza := 15;                     
                IF vnum_err <> 0 THEN --Si fallan esta funciones de gestión salimos del programa
                    p_tab_error(f_sysdate, f_user, vobj, vtraza, vnum_err, 'Error llamando a pac_gestion_procesos.f_set_carga_ctrl_cabecera2');
                    RAISE errorini; --Error que para ejecución
                END IF;
                
                vtraza := 16;
                UTL_FILE.FCLOSE(v_file);
     
                vtraza := 17;
                RAISE vsalir;                
           
          END;  
        
        IF v_nombre IS NOT NULL AND v_apellidos IS NOT NULL THEN           
        
        
            --Insertamos los datos en nuestra tabla propia
            vtraza := 18;    
            INSERT INTO INT_CARGA_CENSOMALTA
                                (PROCESO, NLINEA, NCARGA, NOMBRE, APELLIDOS, NOMBRESOLTERA, DNI, CALLE, VOTANTE, DETALLE, CPOBLAC, CPROVIN)
                         VALUES (psproces, v_numlineaI, null, LTRIM(RTRIM(v_nombre)), LTRIM(RTRIM(v_apellidos)), LTRIM(RTRIM(v_nombresol)), v_dni, v_direccion, v_votante, LTRIM(RTRIM(v_details)), v_poblac, v_provin); 
        
            --Variable para el tratamiento de lineas de los inserts
            v_numlineaI:= v_numlineaI+1;
            
        END IF;
        
            --Variable para el tratamiento de lineas del fichero    
            v_numlineaF:= v_numlineaF+1;  
         
        --Limpiamos variables 
        v_nombre := '';
        v_apellidos := '';
        v_nombresol := '';                
        v_details := '';
        v_dni :=  '';        
        v_eslineaper := FALSE;

        END LOOP;

        COMMIT;
       
        vtraza := 19;
        --Cerramos el archivo 
        UTL_FILE.FCLOSE(v_file);
  
       RETURN 0;
        
       EXCEPTION
            WHEN vsalir THEN
                RETURN 103187; -- error leyendo el fichero
            WHEN e_errdatos THEN
                ROLLBACK;
                p_genera_logs(vobj, vtraza, 'Error ' || SQLCODE, SQLERRM, psproces, 'Error ' || SQLCODE || ' ' || SQLERRM);        
                RETURN vnum_err;
                
            WHEN errorini THEN --Error al insertar estados
                ROLLBACK;                
                p_genera_logs(vobj, vtraza,
                              'Error:' || 'ErrorIni' || ' en :' || vnum_err,
                              'Error:' || 'Insertando estados registros', psproces,
                              f_axis_literales(108953, k_idiomaaaxis) || ':'
                              || v_tfichero || ' : ' || 'errorini');
        
            RETURN 1;
        
        WHEN OTHERS THEN
                
                ROLLBACK;                        
                p_genera_logs(vobj, vtraza, 'Error ' || SQLCODE, SQLERRM, psproces,
                                    'Error ' || SQLCODE || ' ' || SQLERRM);
                vnum_err := pac_gestion_procesos.f_set_carga_ctrl_cabecera(psproces, p_nombre, f_sysdate, NULL, 1, p_cproces, 151541, SQLERRM);
                vtraza := 51;
         
                IF vnum_err <> 0 THEN
                    p_tab_error(f_sysdate, f_user, vobj, vtraza, vnum_err, 'Error llamando a pac_gestion_procesos.f_set_carga_ctrl_cabecera2');
                END IF;
         
        RETURN 1;
        
END f_censo_ejecutarcargafichero; 

FUNCTION f_censo_ejecutarcargaproceso (p_ssproces IN NUMBER) RETURN NUMBER IS
    
    vobj  VARCHAR2(100) := 'PAC_CARGAS_MSV.F_CENSO_EJECUTARCARGAPROCESO';
    v_ntraza   NUMBER := 0;
    e_salir   EXCEPTION;
 
    CURSOR cur_censo(p_ssproces2 IN NUMBER) IS
    SELECT   a.*
      FROM INT_CARGA_CENSOMALTA a
     WHERE proceso = p_ssproces2
    AND NOT EXISTS(
            SELECT 1
              FROM int_carga_ctrl_linea b
             WHERE b.sproces = a.proceso
               AND b.nlinea = a.nlinea
               AND b.cestado IN(2, 4, 5)) -- solo coja las lineas en estado 1(error) y 3 (pendiente) o que no tengan registro int_carga_ctrl_linea
    ORDER BY nlinea;   -- registro tipo certificado
 
    v_toperacion   VARCHAR2(20);
    v_berrorproc   BOOLEAN := FALSE;
    v_berrorlin   BOOLEAN := FALSE;
    v_bavisproc   BOOLEAN := FALSE;
    v_ntipoerror   NUMBER := 0;
    v_nnumerr       NUMBER;
      v_nnumerr1       NUMBER;
    v_tdeserror     VARCHAR2(1000);
    
    vtraza number(5);
    wsinterf      INT_MENSAJES.SINTERF%TYPE;
  
BEGIN

    vtraza := 1;
    FOR x IN cur_censo(p_ssproces) LOOP
    
        vtraza := 2;
        --vamos procesanso las lineas        
        v_nnumerr := p_marcalinea(p_ssproces, x.nlinea, 'PER', 1, 0, NULL, x.dni,
        x.ncarga, NULL, NULL, NULL, NULL);

        vtraza := 3;
        -- Procedemos al alta de personas (censo de Malta) 
        v_nnumerr := f_alta_censo(x, v_tdeserror, wsinterf, p_ssproces);
       
        -- compruebo si tengo algun error y lo marco en las lineas de control     
        IF v_nnumerr <> 0  THEN
          vtraza := 4;  
          v_nnumerr := p_marcalinea(p_ssproces, x.nlinea, 'PER', 1, 0, null, null, --v_id,
          x.ncarga, NULL, NULL, NULL, NULL);
        ELSE
          vtraza := 5;  
          v_nnumerr := p_marcalinea(p_ssproces, x.nlinea, 'PER', 4, 1, null, x.dni, --v_id,
          x.ncarga, NULL, NULL, NULL, NULL);
        END IF;
 
    END LOOP;
    
    vtraza := 6;
    COMMIT;
 
    IF v_berrorproc THEN
        RETURN 1;
    ELSIF v_bavisproc THEN
        RETURN 2;
    ELSE
        RETURN 4;
    END IF;
    
   EXCEPTION
    
    WHEN e_salir THEN
        ROLLBACK;
        -- v_nnumerr := p_marcalinea(p_ssproces, v_id_linea, v_toperacion, 1, 0, NULL, v_id, v_ncarga); 
        -- v_nnumerr := p_marcalineaerror(p_ssproces, v_id_linea, NULL, 1, NVL(v_nnumerr, 1),
        -- NVL(v_tdeserror, -1));
        RETURN 1;
    
    WHEN OTHERS THEN
        v_nnumerr := SQLCODE;
        v_tdeserror := SQLCODE || ' ' || SQLERRM;
        ROLLBACK;
      --  v_nnumerr1 := p_marcalinea(p_ssproces, v_id_linea, 'PER', 1, 0, NULL, v_id, v_ncarga);
     --   v_nnumerr := p_marcalineaerror(p_ssproces, v_id_linea, NULL, 1, v_nnumerr,
     --   v_tdeserror);
        
        p_genera_logs(vobj, vtraza, 'Error ' || v_nnumerr, SQLERRM, p_ssproces,
                                    'Error ' || v_tdeserror);
        
    RETURN 1;
    
    END f_censo_ejecutarcargaproceso;


END pac_cargas_msv; 

/

  GRANT EXECUTE ON "AXIS"."PAC_CARGAS_MSV" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_CARGAS_MSV" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_CARGAS_MSV" TO "PROGRAMADORESCSI";
