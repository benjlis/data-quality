-- derived from https://stackoverflow.com/questions/54193335/how-to-cast-bigint-to-timestamp-with-time-zone-in-postgres-in-an-update
create function try_cast_timestamp(p_in text, 
                                   p_default timestamp with time zone default null)
   returns timestamp with time zone
as
$$
begin
  begin
    return $1::timestamp with time zone;
  exception
    when others then
       return p_default;
  end;
end;
$$
language plpgsql;
