CREATE OR REPLACE FUNCTION f_intermediarios_iva(pnrecibo IN NUMBER) RETURN NUMBER IS
  vobj VARCHAR2(200) := 'f_intermediarios_iva';
  vpas NUMBER := 1;
  vpar VARCHAR2(500) := 'pnrecibo=' || pnrecibo ;
  v_tiene_corretaje NUMBER := 0;
  e_param_error  EXCEPTION;
  vsseguro NUMBER;
  vnmovimi NUMBER;
  vaplicaiva NUMBER;
  vivacoa  NUMBER:=1;
  vagente seguros.cagente%TYPE;
  ragente seguros.cagente%TYPE;  
  vptipiva tipoiva.ptipiva%TYPE;
  -- 
  v_retorno NUMBER := 0;
  --
  v_numerr  NUMBER := 0;
  --
  v_pcomisi comisionprod.pcomisi%TYPE := 0;
  v_icombru comrecibo.icombru%TYPE;
  v_icomret comrecibo.icomret%TYPE;
  --
  v_pcacept NUMBER := 1;
  --
      CURSOR c_corretaje(ppsseguro IN NUMBER,ppnmovimi IN NUMBER) IS
      SELECT cagente
        FROM age_corretaje 
       WHERE sseguro = ppsseguro
         AND nmovimi = ppnmovimi;
  --

BEGIN
    vpas := 10;
    
    IF pnrecibo IS NULL THEN
        RAISE e_param_error;
    END IF;

    vpas := 20;
    
    SELECT sseguro, nmovimi
      INTO vsseguro, vnmovimi
      FROM recibos
     WHERE nrecibo = pnrecibo;
     
    v_tiene_corretaje := pac_corretaje.f_tiene_corretaje(vsseguro,vnmovimi); 
  
    IF v_tiene_corretaje = 0 THEN
    
    vpas := 30;    
    
        BEGIN
            SELECT cagente
              INTO vagente
              FROM recibos
             WHERE nrecibo = pnrecibo;
        EXCEPTION
             WHEN OTHERS THEN
                p_tab_error(f_sysdate, f_user, vobj, vpas, vpar, SQLCODE || ' - ' || SQLERRM);          
        
        END;
    
        BEGIN    --1 SI LE APLICA IVA
                    SELECT (1),tip.ptipiva 
                      INTO vaplicaiva,vptipiva
                      FROM agentes ag, per_personas pp, per_regimenfiscal pr, tipoiva tip
		             WHERE ag.sperson = pp.sperson
                       AND pp.sperson = pr.sperson
                       AND ag.cagente = vagente
                       AND pr.fefecto = (SELECT MAX(fefecto) 
                                           FROM per_regimenfiscal pr2 
                                          WHERE pr2.sperson = ag.sperson
                                            AND pr2.fefecto <= f_sysdate) --me traera solo el tipo de iva que aplica actualmente para el tercero
                       AND pr.ctipiva = 0
                       AND ag.ctipage = 4 --Solo los corredores tienen IVA(desnivelage),agencias o agentes no tienen iva
                       AND tip.ctipiva = ag.ctipiva; 
                       /*AND (SELECT SPERSON   --Se desbloquea el AND para agregar las zonas exentas de iva (cuando se hayan parametrizado en el sistema)
                              FROM agentes 
                             WHERE cagente = pac_redcomercial.f_busca_padre(24,pagente,4,f_sysdate)) NOT IN (SPERSONAMAZONAS,SPERSONSANANDRES)*/ -- (aqui deben incluirse los sperson de AMAZONAS Y SAN ANDRES (TABLA per_detper))    
        EXCEPTION
             WHEN NO_DATA_FOUND THEN
                vaplicaiva := 0;
                vptipiva := 0;
             WHEN OTHERS THEN
                p_tab_error(f_sysdate, f_user, vobj, vpas, vpar, SQLCODE || ' - ' || SQLERRM);             
        END;

    vpas := 40; 
    
    --INI SGM IAXIS 5414  COASEGURO ACEPTADO NO TIENE IVA
        BEGIN
            SELECT DISTINCT p.cimpips
              INTO vivacoa
              FROM seguros s, garanpro p
             WHERE s.sproduc = p.sproduc
               AND s.sseguro = vsseguro;
        EXCEPTION       
        WHEN OTHERS THEN
           p_tab_error(f_sysdate, f_user, vobj, vpas, vpar, SQLCODE || ' - ' || SQLERRM);           
        END;
  p_control_error('SGMO','F_INTERMEDIARIOS_IVA',vivacoa);      
        IF vivacoa = 0 THEN
            vaplicaiva := 0;
        END IF;
    --FIN SGM IAXIS 5414  COASEGURO ACEPTADO NO TIENE IVA
        IF vaplicaiva = 1 AND vptipiva > 0 THEN
                UPDATE comrecibo 
                   SET ivacomisi = round(icombru_moncia * (vptipiva/100))
                 WHERE nrecibo = pnrecibo 
                   AND cagente = vagente;                      
                 COMMIT;             
        ELSIF vaplicaiva = 0 OR vptipiva = 0 THEN
                UPDATE comrecibo 
                   SET ivacomisi = 0
                 WHERE nrecibo = pnrecibo 
                   AND cagente = vagente;                      
                 COMMIT;         
        END IF;
    ELSE
    
    vpas := 50;
        p_control_error('SGM', 'entro al else', 'vsseguro: '||vsseguro||' ; vnmovimi: '||vnmovimi);    
            OPEN c_corretaje(vsseguro,vnmovimi); 
            LOOP
                FETCH c_corretaje INTO ragente; 
                EXIT WHEN c_corretaje%notfound; 
                p_control_error('SGM', 'entro al cursor', ragente);  
            --verificamos si le aplica iva al 3ro(mirando su regimen fiscal actual y domicilio de operación)
                    BEGIN    --1 SI LE APLICA IVA
                                SELECT (1),tip.ptipiva 
                                  INTO vaplicaiva,vptipiva
                                  FROM agentes ag, per_personas pp, per_regimenfiscal pr, tipoiva tip
                                 WHERE ag.sperson = pp.sperson
                                   AND pp.sperson = pr.sperson
                                   AND ag.cagente = ragente
                                   AND pr.fefecto = (SELECT MAX(fefecto) 
                                                       FROM per_regimenfiscal pr2 
                                                      WHERE pr2.sperson = ag.sperson
                                                        AND pr2.fefecto <= f_sysdate) --me traera solo el tipo de iva que aplica actualmente para el tercero
                                   AND pr.ctipiva = 0
                                   AND ag.ctipage = 4 --Solo los corredores tienen IVA(desnivelage),agencias o agentes no tienen iva
                                   AND tip.ctipiva = ag.ctipiva; 
                                   /*AND (SELECT SPERSON   --Se desbloquea el AND para agregar las zonas exentas de iva (cuando se hayan parametrizado en el sistema)
                                          FROM agentes 
                                         WHERE cagente = pac_redcomercial.f_busca_padre(24,pagente,4,f_sysdate)) NOT IN (SPERSONAMAZONAS,SPERSONSANANDRES)*/ -- (aqui deben incluirse los sperson de AMAZONAS Y SAN ANDRES (TABLA per_detper))    
                    EXCEPTION
                         WHEN NO_DATA_FOUND THEN
                            vaplicaiva := 0;
                            vptipiva := 0;
                         WHEN OTHERS THEN
                            p_tab_error(f_sysdate, f_user, vobj, vpas, vpar, SQLCODE || ' - ' || SQLERRM);             
                    END;

    vpas := 60; 
            --INI SGM IAXIS 5414  COASEGURO ACEPTADO NO TIENE IVA
                BEGIN
                    SELECT DISTINCT p.cimpips
                      INTO vivacoa
                      FROM seguros s, garanpro p
                     WHERE s.sproduc = p.sproduc
                       AND s.sseguro = vsseguro;
                EXCEPTION       
                WHEN OTHERS THEN
                   p_tab_error(f_sysdate, f_user, vobj, vpas, vpar, SQLCODE || ' - ' || SQLERRM);           
                END;
          p_control_error('SGMO','F_INTERMEDIARIOS_IVA',vivacoa);      
                IF vivacoa = 0 THEN
                    vaplicaiva := 0;
                END IF;
            --FIN SGM IAXIS 5414  COASEGURO ACEPTADO NO TIENE IVA
                    IF vaplicaiva = 1 AND vptipiva > 0 THEN
                            UPDATE comrecibo 
                               SET ivacomisi = round(icombru_moncia * (vptipiva/100))
                             WHERE nrecibo = pnrecibo 
                               AND cagente = ragente;                      
                             COMMIT;             
                    ELSIF vaplicaiva = 0 OR vptipiva = 0 THEN
                            UPDATE comrecibo 
                               SET ivacomisi = 0
                             WHERE nrecibo = pnrecibo 
                               AND cagente = ragente;                      
                             COMMIT;         
                    END IF;
         END LOOP;    
         CLOSE c_corretaje;     
    END IF;  

  vpas := 181;
  RETURN v_retorno;
EXCEPTION
  WHEN e_param_error THEN
         p_tab_error(f_sysdate, f_user, vobj, vpas, vpar, SQLCODE);
         RETURN 1;
  WHEN OTHERS THEN
    p_tab_error(f_sysdate, f_user, vobj, vpas, vpar,
                'SQLCODE = ' || SQLCODE || ' - ' || 'SQLERRM = ' || SQLERRM || 'v_numerr = ' || v_numerr || ' - ' ||
                 dbms_utility.format_error_backtrace);
    RETURN 3000000;
END f_intermediarios_iva;
/
