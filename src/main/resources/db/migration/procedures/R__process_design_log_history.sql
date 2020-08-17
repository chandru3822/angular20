CREATE OR REPLACE FUNCTION brs.process_design_log_history() RETURNS trigger
    LANGUAGE plpgsql
AS
$$
BEGIN

    INSERT INTO brs.design_log_history(
        project_id ,
        reference_nbr ,
        system_size ,
        annual_production ,
        number_of_modules_mp1 ,
        azimuth_mp1 ,
        pitch_mp1 ,
        tsrf_mp1 ,
        number_of_modules_mp2 ,
        azimuth_mp2 ,
        pitch_mp2 ,
        tsrf_mp2 ,
        number_of_modules_mp3,
        azimuth_mp3 ,
        pitch_mp3 ,
        tsrf_mp3 ,
        number_of_modules_mp4 ,
        azimuth_mp4 ,
        pitch_mp4 ,
        tsrf_mp4 ,
        number_of_modules_mp5 ,
        azimuth_mp5 ,
        pitch_mp5 ,
        tsrf_mp5 ,
        number_of_modules_mp6 ,
        azimuth_mp6 ,
        pitch_mp6 ,
        tsrf_mp6 ,
        adder_amount,
        design_log_date,
        bom
    )
    VALUES (new.project_id,
            new.design_nbr,
            new.design->>'System Size (w)',
            new.design->>'Year 1 kWh Output',
            new.design->>'Number of Modules_mp1',
            new.design->>'Azimuth_mp1',
            new.design->>'Pitch_mp1',
            new.design->>'TSRF_mp1',
            new.design->>'Number of Modules_mp2',
            new.design->>'Azimuth_mp2',
            new.design->>'Pitch_mp2',
            new.design->>'TSRF_mp2',
            new.design->>'Number of Modules_mp3',
            new.design->>'Azimuth_mp3',
            new.design->>'Pitch_mp3',
            new.design->>'TSRF_mp3',
            new.design->>'Number of Modules_mp4',
            new.design->>'Azimuth_mp4',
            new.design->>'Pitch_mp4',
            new.design->>'TSRF_mp4',
            new.design->>'Number of Modules_mp5',
            new.design->>'Azimuth_mp5',
            new.design->>'Pitch_mp5',
            new.design->>'TSRF_mp5',
            new.design->>'Number of Modules_mp6',
            new.design->>'Azimuth_mp6',
            new.design->>'Pitch_mp6',
            new.design->>'TSRF_mp6',
            new.design->>'Adder Amount',
            new.design_date,
            new.bom
           );
    RETURN NEW;
END;
$$;
