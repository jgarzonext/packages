
   /*************************************************************************
      FUNCTION F_Int_Ext_Reporte
         Obtenemos el valor de la participación de las empresas Reaseguradoras del Interior- Exterior y su Retención
         param in p_sseguro  : Número de sseguro 
         param in p_identif    : Número de idetificador de la columna (1)Interior  (0)Exterior (3) Retencion
        --IAXIS 7585 Reporte Siniestros Pagados, Recobros y Reservas - Reaseg - IRDR - 01/04/2020

*************************************************************************/
    
CREATE OR REPLACE EDITIONABLE FUNCTION "AXIS"."F_INT_EXT_REPORTE"(p_sseguro IN NUMBER,
                                             p_valorca IN NUMBER,
                                             p_identif   IN NUMBER)
     RETURN NUMBER IS 
 
    v_ctiprea           NUMBER;
    v_result_resumen    NUMBER;
    v_result_cero       NUMBER; 
    v_result_uno        NUMBER;
    v_result_dos        NUMBER;
    v_result_tres       NUMBER;
    v_result_cinco      NUMBER;
    v_pcesion           NUMBER;
    v_scesrea           NUMBER;
    v_scontra           NUMBER;
    v_nversio           NUMBER;
    v_ctramo            NUMBER;

    v_object       VARCHAR2(200) := 'f_Int_Ext_Reporte';
    v_param        VARCHAR2(500) :=  'p_sseguro:' || p_sseguro || 'p_valorca: ' || p_valorca || 'p_identif: ' || p_identif ;   
    vpasexec       NUMBER(5) := 0;  


BEGIN

--Exterior
IF p_identif = 0 then 

   BEGIN
vpasexec := 1;

        SELECT max(cr.scesrea), cr.nversio, cr.scontra, cr.ctramo, cr.pcesion 
            INTO v_scesrea, v_nversio, v_scontra, v_ctramo, v_pcesion
            FROM cesionesrea cr
            WHERE cr.sseguro = p_sseguro
            AND cr.ctramo = 1
            GROUP BY cr.nversio, cr.scontra, cr.ctramo, cr.pcesion;

EXCEPTION WHEN no_data_found THEN
        v_scontra := 0;
     END;  

   select MAX(c.ctiprea) 
        into v_ctiprea 
        from companias c 
        where c.ctiprea = 0
        and c.ccompani in (select ccompani from cuadroces
                                    where scontra = v_scontra
                                    and nversio = v_nversio
                                    and ctramo = v_ctramo);
 
IF v_ctiprea = 0  and v_ctramo = 1  then  
      
    v_result_uno := (p_valorca * v_pcesion) ;           

END IF;


   BEGIN
vpasexec := 2;
   
      SELECT max(cr.scesrea), cr.nversio, cr.scontra, cr.ctramo, cr.pcesion 
            INTO v_scesrea, v_nversio, v_scontra, v_ctramo, v_pcesion
            FROM cesionesrea cr
            WHERE cr.sseguro = p_sseguro
            AND cr.ctramo = 2
            GROUP BY cr.nversio, cr.scontra, cr.ctramo, cr.pcesion;

EXCEPTION WHEN no_data_found THEN
        v_scontra := 0;
     END;  
           
    select MAX(c.ctiprea) 
        into v_ctiprea 
        from companias c 
        where c.ctiprea = 0
        and c.ccompani in (select ccompani from cuadroces
                                    where scontra = v_scontra
                                    and nversio = v_nversio
                                    and ctramo = v_ctramo);
     
IF v_ctiprea = 0 and v_ctramo = 2 then  
    
    v_result_dos := (p_valorca * v_pcesion) ;           

END IF;
    
   BEGIN
vpasexec := 3;

       SELECT max(cr.scesrea), cr.nversio, cr.scontra, cr.ctramo, cr.pcesion 
            INTO v_scesrea, v_nversio, v_scontra, v_ctramo, v_pcesion
            FROM cesionesrea cr
            WHERE cr.sseguro = p_sseguro
            AND cr.ctramo = 3
            GROUP BY cr.nversio, cr.scontra, cr.ctramo, cr.pcesion;
            
EXCEPTION WHEN no_data_found THEN
        v_nversio := 0;
     END;  
               
select MAX(c.ctiprea) 
        into v_ctiprea 
        from companias c 
        where c.ctiprea = 0
        and c.ccompani in (select ccompani from cuadroces
                                    where scontra = v_scontra
                                    and nversio = v_nversio
                                    and ctramo = v_ctramo);

IF v_ctiprea = 0 and v_ctramo = 3 then  
    
    v_result_tres := (p_valorca * v_pcesion) ;           

END IF;
  
   v_result_resumen := nvl(v_result_uno, 0) + nvl(v_result_dos, 0) + nvl(v_result_tres, 0);-- + v_result_cinco; 
 
 END IF;
 

--Interior
IF p_identif = 1 then 

   BEGIN
vpasexec := 4;

        SELECT max(cr.scesrea), cr.nversio, cr.scontra, cr.ctramo, cr.pcesion 
            INTO v_scesrea, v_nversio, v_scontra, v_ctramo, v_pcesion
            FROM cesionesrea cr
            WHERE cr.sseguro = p_sseguro
            AND cr.ctramo = 1
            GROUP BY cr.nversio, cr.scontra, cr.ctramo, cr.pcesion;

EXCEPTION WHEN no_data_found THEN
        v_scontra := 0;
     END;  

   select MAX(c.ctiprea) 
        into v_ctiprea 
        from companias c 
        where c.ctiprea = 1
        and c.ccompani in (select ccompani from cuadroces
                                    where scontra = v_scontra
                                    and nversio = v_nversio
                                    and ctramo = v_ctramo);
 
IF v_ctiprea = 1  and v_ctramo = 1  then  
      
    v_result_uno := (p_valorca * v_pcesion) ;           

END IF;


   BEGIN
vpasexec := 5;
   
      SELECT max(cr.scesrea), cr.nversio, cr.scontra, cr.ctramo, cr.pcesion 
            INTO v_scesrea, v_nversio, v_scontra, v_ctramo, v_pcesion
            FROM cesionesrea cr
            WHERE cr.sseguro = p_sseguro
            AND cr.ctramo = 2
            GROUP BY cr.nversio, cr.scontra, cr.ctramo, cr.pcesion;

EXCEPTION WHEN no_data_found THEN
        v_scontra := 0;
     END;  
           
    select MAX(c.ctiprea) 
        into v_ctiprea 
        from companias c 
        where c.ctiprea = 1
        and c.ccompani in (select ccompani from cuadroces
                                    where scontra = v_scontra
                                    and nversio = v_nversio
                                    and ctramo = v_ctramo);
     
IF v_ctiprea = 1 and v_ctramo = 2 then  
    
    v_result_dos := (p_valorca * v_pcesion) ;           

END IF;
    
   BEGIN
vpasexec := 6;

       SELECT max(cr.scesrea), cr.nversio, cr.scontra, cr.ctramo, cr.pcesion 
            INTO v_scesrea, v_nversio, v_scontra, v_ctramo, v_pcesion
            FROM cesionesrea cr
            WHERE cr.sseguro = p_sseguro
            AND cr.ctramo = 3
            GROUP BY cr.nversio, cr.scontra, cr.ctramo, cr.pcesion;
            
EXCEPTION WHEN no_data_found THEN
        v_nversio := 0;
     END;  
               
select MAX(c.ctiprea) 
        into v_ctiprea 
        from companias c 
        where c.ctiprea = 1
        and c.ccompani in (select ccompani from cuadroces
                                    where scontra = v_scontra
                                    and nversio = v_nversio
                                    and ctramo = v_ctramo);
IF v_ctiprea = 1 and v_ctramo = 3 then  
    
    v_result_tres := (p_valorca * v_pcesion) ;           

END IF;
  
   v_result_resumen := nvl(v_result_uno, 0) + nvl(v_result_dos, 0) + nvl(v_result_tres, 0);-- + v_result_cinco; 
 
 END IF;
  
 
 
--retencion  
IF p_identif = 3 then 

   BEGIN
vpasexec := 7;

        SELECT max(cr.scesrea), cr.nversio, cr.scontra, cr.ctramo, cr.pcesion 
            INTO v_scesrea, v_nversio, v_scontra, v_ctramo, v_pcesion
            FROM cesionesrea cr
            WHERE cr.sseguro = p_sseguro
            AND cr.ctramo = 0
            GROUP BY cr.nversio, cr.scontra, cr.ctramo, cr.pcesion;

EXCEPTION WHEN no_data_found THEN
        v_scontra := 0;
     END;  


IF v_ctramo = 0  then  
      
    v_result_cero := (p_valorca * v_pcesion) ;           
    v_result_resumen := v_result_cero;

END IF;

    END IF;

  
          RETURN v_result_resumen;  
 EXCEPTION
      WHEN OTHERS THEN
         p_tab_error(f_sysdate,
                     f_user,
                     v_object,
                     vpasexec,
                     v_param,
                     'SQLERROR: ' || SQLCODE || ' - ' || SQLERRM);
      RETURN 1;
END F_INT_EXT_REPORTE;
/
  GRANT EXECUTE ON "AXIS"."F_INT_EXT_REPORTE" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."F_INT_EXT_REPORTE" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."F_INT_EXT_REPORTE" TO "PROGRAMADORESCSI";
