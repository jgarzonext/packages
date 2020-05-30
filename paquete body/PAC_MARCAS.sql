CREATE OR REPLACE PACKAGE BODY pac_marcas
AS
     /******************************************************************************
           NOMBRE:       PAC_MARCAS
           PROP¿SITO:  Funciones para gestionar las marcas

           REVISIONES:
           Ver        Fecha        Autor   Descripci¿n
          ---------  ----------  ------   ------------------------------------
           1.0        01/08/2016   HRE     1. Creaci¿n del package.
           2.0        19/02/2019   CJMR    2. TCS-344: Nuevo funcional Marcas: Nuevo vínculo proveedor
           3.0        05/03/2019   WAJ     3. Se hace llamado a funcion para la convivencia con Osiris
           4.0        05/03/2019   CJMR    4. Se agrega función para validación de marcas
           5.0        15/06/2019   ECP     5. IAXIS-3981. Marcas Integrantes Consorcios y Uniones Temporales
           6.0        18/03/2020   SP      6. Cambios de IAXIS-13044
           7.0        30/03/2020   SP      7. IAXIS-13006 : Cambios de Web Compliance		   
   ******************************************************************************/
     /*************************************************************************
       FUNCTION f_set_marcas_per
       Permite asociar marcas a la persona de forma manual
       param in pcempres  : codigo de la empresa
       param in psperson  : codigo de la persona
       param in pcmarca   : codigo de la marca
       param in pparam    : parametros de roles
       param out mensajes : mesajes de error
       return             : number
     *************************************************************************/
   FUNCTION f_set_marcas_per (
      pcempres   IN   NUMBER,
      psperson   IN   NUMBER,
      t_marcas   IN   t_iax_marcas
   )
      RETURN NUMBER
   IS
      CURSOR cur_per_marca (
         ppempres    per_agr_marcas.cempres%TYPE,
         ppsperson   per_agr_marcas.sperson%TYPE,
         ppcmarca    per_agr_marcas.cmarca%TYPE
      )
      IS
         SELECT *
           FROM per_agr_marcas a
          WHERE cempres = ppempres
            AND sperson = ppsperson
            AND cmarca = ppcmarca
            AND nmovimi =
                   (SELECT MAX (nmovimi)
                      FROM per_agr_marcas b
                     WHERE a.cempres = b.cempres
                       AND a.sperson = b.sperson
                       AND a.cmarca = b.cmarca);

      CURSOR cur_nmovimi (
         ppempres    per_agr_marcas.cempres%TYPE,
         ppsperson   per_agr_marcas.sperson%TYPE,
         ppcmarca    per_agr_marcas.cmarca%TYPE
      )
      IS
         SELECT NVL (MAX (nmovimi), 0)
           FROM per_agr_marcas
          WHERE cempres = ppempres AND sperson = ppsperson
                AND cmarca = ppcmarca;

      CURSOR cur_agr_marcas (
         ppempres   per_agr_marcas.cempres%TYPE,
         ppcmarca   per_agr_marcas.cmarca%TYPE
      )
      IS
         SELECT *
           FROM agr_marcas
          WHERE cempres = ppempres AND cmarca = ppcmarca;

      v_per_marca       VARCHAR2 (1000);
      v_per_marca2      VARCHAR2 (1000);
      ob_marcas         ob_iax_marcas;
      vpasexec          NUMBER (8)                    := 1;
      vparam            VARCHAR2 (2000)
                        := 'pcempres=' || pcempres || ' psperson=' || psperson;
      vobject           VARCHAR2 (200)        := 'pac_marcas.f_set_marcas_per';
      v_nmovimi         per_agr_marcas.nmovimi%TYPE;
      rg_agr_marcas     agr_marcas%ROWTYPE;
      rg_per_marcas     per_agr_marcas%ROWTYPE;
      rg_per_marcas2    per_agr_marcas%ROWTYPE;
      /* Cambios de  tarea IAXIS-13044 : start */
      VPERSON_NUM_ID    number;
    /* Cambios de  tarea IAXIS-13044 : end */
   BEGIN
      --
      FOR indice IN t_marcas.FIRST .. t_marcas.LAST
      LOOP
         ob_marcas := t_marcas (indice);

         OPEN cur_per_marca (pcempres, psperson, ob_marcas.cmarca);

         FETCH cur_per_marca
          INTO rg_per_marcas;

         CLOSE cur_per_marca;

         IF (rg_per_marcas.cmarca IS NOT NULL)
         THEN
            IF (ob_marcas.ctomador IS NULL)
            THEN
               rg_per_marcas2.ctomador := rg_per_marcas.ctomador;
            ELSE
               rg_per_marcas2.ctomador := ob_marcas.ctomador;
            END IF;

            IF (ob_marcas.cconsorcio IS NULL)
            THEN
               rg_per_marcas2.cconsorcio := rg_per_marcas.cconsorcio;
            ELSE
               rg_per_marcas2.cconsorcio := ob_marcas.cconsorcio;
            END IF;

            IF (ob_marcas.casegurado IS NULL)
            THEN
               rg_per_marcas2.casegurado := rg_per_marcas.casegurado;
            ELSE
               rg_per_marcas2.casegurado := ob_marcas.casegurado;
            END IF;

            IF (ob_marcas.ccodeudor IS NULL)
            THEN
               rg_per_marcas2.ccodeudor := rg_per_marcas.ccodeudor;
            ELSE
               rg_per_marcas2.ccodeudor := ob_marcas.ccodeudor;
            END IF;

            IF (ob_marcas.cbenef IS NULL)
            THEN
               rg_per_marcas2.cbenef := rg_per_marcas.cbenef;
            ELSE
               rg_per_marcas2.cbenef := ob_marcas.cbenef;
            END IF;

            IF (ob_marcas.caccionista IS NULL)
            THEN
               rg_per_marcas2.caccionista := rg_per_marcas.caccionista;
            ELSE
               rg_per_marcas2.caccionista := ob_marcas.caccionista;
            END IF;

            IF (ob_marcas.cintermed IS NULL)
            THEN
               rg_per_marcas2.cintermed := rg_per_marcas.cintermed;
            ELSE
               rg_per_marcas2.cintermed := ob_marcas.cintermed;
            END IF;

            IF (ob_marcas.crepresen IS NULL)
            THEN
               rg_per_marcas2.crepresen := rg_per_marcas.crepresen;
            ELSE
               rg_per_marcas2.crepresen := ob_marcas.crepresen;
            END IF;

            IF (ob_marcas.capoderado IS NULL)
            THEN
               rg_per_marcas2.capoderado := rg_per_marcas.capoderado;
            ELSE
               rg_per_marcas2.capoderado := ob_marcas.capoderado;
            END IF;

            IF (ob_marcas.cpagador IS NULL)
            THEN
               rg_per_marcas2.cpagador := rg_per_marcas.cpagador;
            ELSE
               rg_per_marcas2.cpagador := ob_marcas.cpagador;
            END IF;

            -- INI CJMR TCS-344 19/02/2019
            IF (ob_marcas.cproveedor IS NULL)
            THEN
               rg_per_marcas2.cproveedor := rg_per_marcas.cproveedor;
            ELSE
               rg_per_marcas2.cproveedor := ob_marcas.cproveedor;
            END IF;

            -- FIN CJMR TCS-344 19/02/2019
            IF (ob_marcas.observacion IS NULL)
            THEN
               rg_per_marcas2.observacion := rg_per_marcas.observacion;
            ELSE
               rg_per_marcas2.observacion := ob_marcas.observacion;
            END IF;
         ELSE
            rg_per_marcas2.ctomador := NVL (ob_marcas.ctomador, 0);
            rg_per_marcas2.cconsorcio := NVL (ob_marcas.cconsorcio, 0);
            rg_per_marcas2.casegurado := NVL (ob_marcas.casegurado, 0);
            rg_per_marcas2.ccodeudor := NVL (ob_marcas.ccodeudor, 0);
            rg_per_marcas2.cbenef := NVL (ob_marcas.cbenef, 0);
            rg_per_marcas2.caccionista := NVL (ob_marcas.caccionista, 0);
            rg_per_marcas2.cintermed := NVL (ob_marcas.cintermed, 0);
            rg_per_marcas2.crepresen := NVL (ob_marcas.crepresen, 0);
            rg_per_marcas2.capoderado := NVL (ob_marcas.capoderado, 0);
            rg_per_marcas2.cpagador := NVL (ob_marcas.cpagador, 0);
            -- INI CJMR TCS-344 19/02/2019
            rg_per_marcas2.cproveedor := NVL (ob_marcas.cproveedor, 0);
            -- FIN CJMR TCS-344 19/02/2019
            rg_per_marcas2.observacion := ob_marcas.observacion;
         END IF;

         OPEN cur_agr_marcas (pcempres, ob_marcas.cmarca);

         FETCH cur_agr_marcas
          INTO rg_agr_marcas;

         CLOSE cur_agr_marcas;

         IF (rg_agr_marcas.ctomador = 0)
         THEN
            rg_per_marcas2.ctomador := 0;
         END IF;

         IF (rg_agr_marcas.cconsorcio = 0)
         THEN
            rg_per_marcas2.cconsorcio := 0;
         END IF;

         IF (rg_agr_marcas.casegurado = 0)
         THEN
            rg_per_marcas2.casegurado := 0;
         END IF;

         IF (rg_agr_marcas.ccodeudor = 0)
         THEN
            rg_per_marcas2.ccodeudor := 0;
         END IF;

         IF (rg_agr_marcas.cbenef = 0)
         THEN
            rg_per_marcas2.cbenef := 0;
         END IF;

         IF (rg_agr_marcas.caccionista = 0)
         THEN
            rg_per_marcas2.caccionista := 0;
         END IF;

         IF (rg_agr_marcas.cintermed = 0)
         THEN
            rg_per_marcas2.cintermed := 0;
         END IF;

         IF (rg_agr_marcas.crepresen = 0)
         THEN
            rg_per_marcas2.crepresen := 0;
         END IF;

         IF (rg_agr_marcas.capoderado = 0)
         THEN
            rg_per_marcas2.capoderado := 0;
         END IF;

         IF (rg_agr_marcas.cpagador = 0)
         THEN
            rg_per_marcas2.cpagador := 0;
         END IF;

         -- INI CJMR TCS-344 19/02/2019
         IF (rg_agr_marcas.cproveedor = 0)
         THEN
            rg_per_marcas2.cproveedor := 0;
         END IF;

         -- FIN CJMR TCS-344 19/02/2019
         v_per_marca :=
               rg_per_marcas.cempres
            || rg_per_marcas.sperson
            || rg_per_marcas.ctomador
            || rg_per_marcas.cconsorcio
            || rg_per_marcas.casegurado
            || rg_per_marcas.ccodeudor
            || rg_per_marcas.caccionista
            || rg_per_marcas.cintermed
            || rg_per_marcas.crepresen
            || rg_per_marcas.capoderado
            || rg_per_marcas.cpagador
            || rg_per_marcas.cproveedor
            ||                                       --CJMR TCS-344 19/02/2019
               NVL (rg_per_marcas.observacion, 'X');
         v_per_marca2 :=
               ob_marcas.cempres
            || ob_marcas.sperson
            || NVL (ob_marcas.ctomador, rg_per_marcas.ctomador)
            || NVL (ob_marcas.cconsorcio, rg_per_marcas.cconsorcio)
            || NVL (ob_marcas.casegurado, rg_per_marcas.casegurado)
            || NVL (ob_marcas.ccodeudor, rg_per_marcas.ccodeudor)
            || NVL (ob_marcas.cbenef, rg_per_marcas.cbenef)
            || NVL (ob_marcas.caccionista, rg_per_marcas.caccionista)
            || NVL (ob_marcas.cintermed, rg_per_marcas.cintermed)
            || NVL (ob_marcas.crepresen, rg_per_marcas.crepresen)
            || NVL (ob_marcas.capoderado, rg_per_marcas.capoderado)
            || NVL (ob_marcas.cpagador, rg_per_marcas.cpagador)
            || NVL (ob_marcas.cproveedor, rg_per_marcas.cproveedor)
            ||                                       --CJMR TCS-344 19/02/2019
               NVL (ob_marcas.observacion, rg_per_marcas.observacion);
                                                     --CJMR TCS-344 19/02/2019

         IF (v_per_marca IS NULL OR v_per_marca != v_per_marca2)
         THEN
            OPEN cur_nmovimi (pcempres, psperson, ob_marcas.cmarca);

            FETCH cur_nmovimi
             INTO v_nmovimi;

            CLOSE cur_nmovimi;

            INSERT INTO per_agr_marcas
                 VALUES (pcempres, psperson, ob_marcas.cmarca, v_nmovimi + 1,
                         0, rg_per_marcas2.ctomador,
                         rg_per_marcas2.cconsorcio,
                         rg_per_marcas2.casegurado, rg_per_marcas2.ccodeudor,
                         rg_per_marcas2.cbenef, rg_per_marcas2.caccionista,
                         rg_per_marcas2.cintermed, rg_per_marcas2.crepresen,
                         rg_per_marcas2.capoderado, rg_per_marcas2.cpagador,
                         rg_per_marcas2.observacion, f_user, f_sysdate,
                         rg_per_marcas2.cproveedor);
                                                    --CJMR TCS-344 19/02/2019
         END IF;
      END LOOP;
      
      /* Cambios de Swapnil para Convivencia :start */
         BEGIN
           SELECT PP.NNUMIDE
             INTO VPERSON_NUM_ID
             FROM PER_PERSONAS PP
            WHERE PP.SPERSON = PSPERSON;
         
           PAC_CONVIVENCIA.P_SEND_DATA_CONVI(VPERSON_NUM_ID,
                                             1,
                                             'S03501',
                                             NULL);
				EXCEPTION
				WHEN OTHERS
				THEN
				 p_tab_error (f_sysdate,
							  f_user,
							  'PAC_MARCAS.f_set_marcas_per',
							  1,
							  'Error PAC_CONVIVENCIA.P_SEND_DATA_CONVI',
							  SQLERRM
							 );                                                            												  
			    END;			         
      /* Cambios de Swapnil para Convivencia :end */ 
      

      RETURN 0;
   EXCEPTION
      WHEN OTHERS
      THEN
         p_tab_error (f_sysdate,
                      f_user,
                      'pac_marcas.f_set_marcas_per',
                      1,
                      'error al insertar, no controlado',
                      SQLERRM
                     );
         RETURN 1;
   END f_set_marcas_per;

/*************************************************************************
    FUNCTION f_set_marca_automatica
    Permite asociar   marcas a la persona en procesos del Sistema
    param in pcempres  : codigo de la empresa
    param in psperson  : codigo de la persona
    param in pcmarca   : codigo de la marca
    param in pparam    : parametros de roles
    param out mensajes : mesajes de error
    return             : number
  *************************************************************************/
   FUNCTION f_set_marca_automatica (
      pcempres   IN   NUMBER,
      psperson   IN   NUMBER,
      pcmarca    IN   VARCHAR2
   )
      RETURN NUMBER
   IS
      CURSOR cur_nmovimi
      IS
         SELECT NVL (MAX (nmovimi), 1)
           FROM per_agr_marcas
          WHERE cempres = pcempres AND sperson = psperson
                AND cmarca = pcmarca;

      CURSOR cur_agr_marcas
      IS
         SELECT *
           FROM agr_marcas
          WHERE cempres = pcempres AND cmarca = pcmarca;

      CURSOR cur_per_agr_marcas
      IS
         SELECT *
           FROM per_agr_marcas a
          WHERE cempres = pcempres
            AND sperson = psperson
            AND cmarca = pcmarca
            AND nmovimi =
                   (SELECT MAX (nmovimi)
                      FROM per_agr_marcas b
                     WHERE a.cempres = b.cempres
                       AND a.sperson = b.sperson
                       AND a.cmarca = b.cmarca);

      v_nmovimi         per_agr_marcas.nmovimi%TYPE;
      rg_agr_marcas     agr_marcas%ROWTYPE;
      rg_per_marcas     per_agr_marcas%ROWTYPE;
      v_per_marca       VARCHAR2 (1000);
      v_per_marca2      VARCHAR2 (1000);
      v_param           VARCHAR2 (500)
         :=    'pcempres: '
            || pcempres
            || ' psperson:'
            || psperson
            || ' pcmarca;'
            || pcmarca;
  /* Cambios de  tarea IAXIS-13044 : start */            
      VPERSON_NUM_ID number;
    /* Cambios de  tarea IAXIS-13044 : end */   
   BEGIN
      OPEN cur_nmovimi;

      FETCH cur_nmovimi
       INTO v_nmovimi;

      CLOSE cur_nmovimi;

      OPEN cur_agr_marcas;

      FETCH cur_agr_marcas
       INTO rg_agr_marcas;

      CLOSE cur_agr_marcas;

      OPEN cur_per_agr_marcas;

      FETCH cur_per_agr_marcas
       INTO rg_per_marcas;

      CLOSE cur_per_agr_marcas;

      v_per_marca :=
            rg_per_marcas.cempres
         || rg_per_marcas.ctomador
         || rg_per_marcas.cconsorcio
         || rg_per_marcas.casegurado
         || rg_per_marcas.ccodeudor
         || rg_per_marcas.cbenef
         || rg_per_marcas.caccionista
         || rg_per_marcas.cintermed
         || rg_per_marcas.crepresen
         || rg_per_marcas.capoderado
         || rg_per_marcas.cpagador
         || rg_per_marcas.cproveedor;               -- CJMR TCS-344 19/02/2019
      v_per_marca2 :=
            rg_agr_marcas.cempres
         || rg_agr_marcas.ctomador
         || rg_agr_marcas.cconsorcio
         || rg_agr_marcas.casegurado
         || rg_agr_marcas.ccodeudor
         || rg_agr_marcas.cbenef
         || rg_agr_marcas.caccionista
         || rg_agr_marcas.cintermed
         || rg_agr_marcas.crepresen
         || rg_agr_marcas.capoderado
         || rg_agr_marcas.cpagador
         || rg_agr_marcas.cproveedor;               -- CJMR TCS-344 19/02/2019

      IF (rg_per_marcas.cempres IS NULL OR v_per_marca != v_per_marca2)
      THEN
         INSERT INTO per_agr_marcas
              VALUES (pcempres, psperson, pcmarca, v_nmovimi + 1, 1,
                      rg_agr_marcas.ctomador, rg_agr_marcas.cconsorcio,
                      rg_agr_marcas.casegurado, rg_agr_marcas.ccodeudor,
                      rg_agr_marcas.cbenef, rg_agr_marcas.caccionista,
                      rg_agr_marcas.cintermed, rg_agr_marcas.crepresen,
                      rg_agr_marcas.capoderado, rg_agr_marcas.cpagador,
                      'Marcación Automática', f_user, f_sysdate,
                      rg_agr_marcas.cproveedor);   -- CJMR TCS-344 19/02/2019
      
      /* Cambios de Swapnil para Convivencia :start */
         BEGIN
           SELECT PP.NNUMIDE
             INTO VPERSON_NUM_ID
             FROM PER_PERSONAS PP
            WHERE PP.SPERSON = PSPERSON;
         
           PAC_CONVIVENCIA.P_SEND_DATA_CONVI(VPERSON_NUM_ID,
                                             1,
                                             'S03501',
                                             NULL);
				EXCEPTION
				WHEN OTHERS
				THEN
				 p_tab_error (f_sysdate,
							  f_user,
							  'PAC_MARCAS.f_set_marca_automatica',
							  1,
							  'Error PAC_CONVIVENCIA.P_SEND_DATA_CONVI',
							  SQLERRM
							 );                                                            												  
			    END;			                  
      /* Cambios de Swapnil para Convivencia :end */ 
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS
      THEN
         p_tab_error (f_sysdate,
                      f_user,
                      'pac_marcas.f_set_marca_automatica',
                      1,
                      'when others pcparam =' || v_param,
                      SQLERRM
                     );
         RETURN 9909279;
   END f_set_marca_automatica;

/*************************************************************************
    FUNCTION f_del_marca_automatica
    Permite desactivar marcas a la persona
    param in pcempres  : codigo de la empresa
    param in psperson  : codigo de la persona
    param in pcmarca   : codigo de la marca
    param out mensajes : mesajes de error
    return             : number
  *************************************************************************/
   FUNCTION f_del_marca_automatica (
      pcempres   IN   NUMBER,
      psperson   IN   NUMBER,
      pcmarca    IN   VARCHAR2
   )
      RETURN NUMBER
   IS
      CURSOR cur_nmovimi
      IS
         SELECT NVL (MAX (nmovimi), 1)
           FROM per_agr_marcas
          WHERE cempres = pcempres AND sperson = psperson
                AND cmarca = pcmarca;

      CURSOR cur_per_agr_marcas
      IS
         SELECT *
           FROM per_agr_marcas a
          WHERE cempres = pcempres
            AND sperson = psperson
            AND cmarca = pcmarca
            AND nmovimi =
                   (SELECT MAX (nmovimi)
                      FROM per_agr_marcas b
                     WHERE a.cempres = b.cempres
                       AND a.sperson = b.sperson
                       AND a.cmarca = b.cmarca);

      v_nmovimi         per_agr_marcas.nmovimi%TYPE;
      rg_per_marcas     per_agr_marcas%ROWTYPE;
      v_per_marca       VARCHAR2 (1000);
      v_per_marca2      VARCHAR2 (1000);

  /* Cambios de  tarea IAXIS-13044 : start */            
      VPERSON_NUM_ID number;
    /* Cambios de  tarea IAXIS-13044 : end */      

      v_param           VARCHAR2 (500)
         :=    'pcempres: '
            || pcempres
            || ' psperson:'
            || psperson
            || ' pcmarca;'
            || pcmarca;
   BEGIN
      OPEN cur_nmovimi;

      FETCH cur_nmovimi
       INTO v_nmovimi;

      CLOSE cur_nmovimi;

      OPEN cur_per_agr_marcas;

      FETCH cur_per_agr_marcas
       INTO rg_per_marcas;

      CLOSE cur_per_agr_marcas;

      v_per_marca :=
            rg_per_marcas.cempres
         || rg_per_marcas.ctomador
         || rg_per_marcas.cconsorcio
         || rg_per_marcas.casegurado
         || rg_per_marcas.ccodeudor
         || rg_per_marcas.caccionista
         || rg_per_marcas.cintermed
         || rg_per_marcas.crepresen
         || rg_per_marcas.capoderado
         || rg_per_marcas.cpagador
         || rg_per_marcas.cproveedor;               -- CJMR TCS-344 19/02/2019
      v_per_marca2 := rg_per_marcas.cempres || '00000000000';
                                                    -- CJMR TCS-344 19/02/2019

      IF (rg_per_marcas.cempres IS NULL OR v_per_marca != v_per_marca2)
      THEN
         INSERT INTO per_agr_marcas
              VALUES (pcempres, psperson, pcmarca, v_nmovimi + 1, 1, 0, 0, 0,
                      0, 0, 0, 0, 0, 0, 0, 'Desmarcaión automática', f_user,
                      f_sysdate, 0);               -- CJMR TCS-344 19/02/2019
      END IF;

      /* Cambios de Swapnil para Convivencia :start */
         BEGIN
           SELECT PP.NNUMIDE
             INTO VPERSON_NUM_ID
             FROM PER_PERSONAS PP
            WHERE PP.SPERSON = PSPERSON;
         
           PAC_CONVIVENCIA.P_SEND_DATA_CONVI(VPERSON_NUM_ID,
                                             1,
                                             'S03501',
                                             NULL);
         EXCEPTION
				WHEN OTHERS
				THEN
				 p_tab_error (f_sysdate,
							  f_user,
							  'PAC_MARCAS.f_del_marca_automatica',
							  1,
							  'Error PAC_CONVIVENCIA.P_SEND_DATA_CONVI',
							  SQLERRM
							 );                                                            												  
			    END;			         	
      /* Cambios de Swapnil para Convivencia :end */ 

      RETURN 0;
   EXCEPTION
      WHEN OTHERS
      THEN
         p_tab_error (f_sysdate,
                      f_user,
                      'pac_marcas.f_del_marca_automatica',
                      1,
                      'when others pcparam =' || v_param,
                      SQLERRM
                     );
         RETURN 9909279;
   END f_del_marca_automatica;

--
/*************************************************************************
    FUNCTION f_ins_log_marcaspoliza
    Inserta informacion de personas que tienen marcas activas
    param in pcempres  : codigo de la empresa
    param in psperson  : codigo de la persona
    param in pcmarca   : codigo de la marca
    param out mensajes : mesajes de error
    return             : number
  *************************************************************************/
   FUNCTION f_ins_log_marcaspoliza (
      pcempres   IN   NUMBER,
      psproces   IN   NUMBER,
      psperson   IN   NUMBER,
      pcmarca    IN   VARCHAR2,
      psseguro   IN   NUMBER
   )
      RETURN NUMBER
   IS
      v_param   VARCHAR2 (500)
         :=    'pcempres: '
            || pcempres
            || ' psproces:'
            || psproces
            || ' psperson:'
            || psperson
            || ' pcmarca;'
            || pcmarca
            || ' psseguro:'
            || psseguro;
   BEGIN
      INSERT INTO log_marcas_polizas
           VALUES (pcempres, psproces, psseguro, psperson, pcmarca, f_user,
                   f_sysdate);

      RETURN 0;
   EXCEPTION
      WHEN OTHERS
      THEN
         p_tab_error (f_sysdate,
                      f_user,
                      'pac_marcas.f_ins_log_marcaspoliza',
                      1,
                      'when others pcparam =' || v_param,
                      SQLERRM
                     );
         RETURN 9909279;
   END f_ins_log_marcaspoliza;

   -- INI CJMR 05/03/2019
/*************************************************************************
    FUNCTION f_marcas_validacion
    Valida si una persona tiene una marca tipo validación en un vinculo específico
    param in psperson  : código de la persona
    param in ptipvin   : Tipo vinculación: 1-Tomador, 2-Asegurado
    param out mensajes : mesajes de error
    return             : number
  *************************************************************************/
   FUNCTION f_marcas_validacion (
      psperson   IN       NUMBER,
      ptipvin    IN       NUMBER,
      mensajes   IN OUT   t_iax_mensajes
   )
      RETURN NUMBER
   IS
      v_validamarca   BOOLEAN := FALSE;
-- IAXIS-3981 -- ECP -- 15/06/2019
      CURSOR c_marcas (p_sperson NUMBER)
      IS
         SELECT pam.*, am.slitera
           FROM agr_marcas am, per_agr_marcas pam
          WHERE am.caacion = 2
            AND pam.cmarca = am.cmarca
            AND pam.sperson = p_sperson
            AND pam.nmovimi =
                    (SELECT MAX (p.nmovimi)
                       FROM per_agr_marcas p
                      WHERE p.sperson = pam.sperson AND p.cmarca = pam.cmarca)
         UNION
         SELECT pam.*, am.slitera
           FROM agr_marcas am, per_agr_marcas pam
          WHERE am.caacion = 2
            AND pam.cmarca = am.cmarca
            AND pam.sperson in (SELECT sperson_rel
                                 FROM per_personas_rel
                                WHERE sperson = psperson)
            AND pam.nmovimi =
                    (SELECT MAX (p.nmovimi)
                       FROM per_agr_marcas p
                      WHERE p.sperson = pam.sperson AND p.cmarca = pam.cmarca);
                      -- IAXIS - 3981 -- ECP -- 15/06/2019
   BEGIN
      FOR marcas_per IN c_marcas (psperson)
      LOOP
         IF    (ptipvin = 1 AND marcas_per.ctomador = 1)
            OR                                                      -- Tomador
               (ptipvin = 2 AND marcas_per.casegurado = 1
               )
            OR                                                   -- Aseguraado
               (ptipvin = 3 AND marcas_per.ccodeudor = 1
               )                                                 -- Codeudor         
              /* IAXIS-13006 : Cambios de Web Compliance : start  */
            OR
              (ptipvin = 4 AND marcas_per.cbenef = 1
               )                                                 -- Beneficiario
               /* IAXIS-13006 : Cambios de Web Compliance : end  */              
         THEN			                             
            v_validamarca := TRUE;
            pac_iobj_mensajes.crea_nuevo_mensaje (mensajes,
                                                  1,
                                                  marcas_per.slitera
                                                 );
         END IF;
      END LOOP;

      IF (v_validamarca)
      THEN
         RETURN 1;
      END IF;

      RETURN 0;
   EXCEPTION
      WHEN OTHERS
      THEN
         p_tab_error (f_sysdate,
                      f_user,
                      'pac_marcas.f_marcas_validacion',
                      1,
                      'when others pcparam ',
                      SQLERRM
                     );
         RETURN 1;
   END f_marcas_validacion;

   -- FIN CJMR 05/03/2019

   /*************************************************************************
     FUNCTION f_get_tipo_marca
     Permite buscar todos as marcas que a persona tienes
     param in pcempres  : codigo de la empresa
     param in psperson  : codigo de la persona
     param out mensajes : mesajes de error
     return             : varchar2
   *************************************************************************/
   FUNCTION f_get_tipo_marca (pcempres IN NUMBER, psperson IN NUMBER)
      RETURN VARCHAR2
   IS
      v_text   VARCHAR2 (500);

      CURSOR cur_marcas
      IS
         SELECT DISTINCT c.tatribu area
                    FROM agr_marcas a,
                         per_agr_marcas b,
                         detvalores c,
                         detvalores d
                   WHERE a.cempres = b.cempres
                     AND a.cmarca = b.cmarca
                     AND a.cempres = pcempres
                     AND b.sperson = psperson
                     AND a.carea = c.catribu
                     AND c.cvalor = 8002004
                     AND c.cidioma = pac_md_common.f_get_cxtidioma
                     AND a.caacion = d.catribu
                     AND d.cvalor = 8002008
                     AND d.cidioma = pac_md_common.f_get_cxtidioma
                     AND b.nmovimi =
                            (SELECT MAX (nmovimi)
                               FROM per_agr_marcas e
                              WHERE b.cempres = e.cempres
                                AND b.cmarca = e.cmarca
                                AND b.sperson = e.sperson);
   BEGIN
      FOR v_tp_marcas IN cur_marcas
      LOOP
         v_text := v_text || v_tp_marcas.area || ', ';
      END LOOP;

      v_text := SUBSTR (v_text, 0, LENGTH (v_text) - 2);
      RETURN v_text;
   END f_get_tipo_marca;
-- FIN F_GET_MARCA 06/06/2019
END pac_marcas;
/