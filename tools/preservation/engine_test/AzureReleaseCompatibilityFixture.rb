module AzureReleaseCompatibilityFixture
  STATUS_PATH=File.join(Dir.pwd,"release_compatibility_runtime.status.txt")
  FIXTURE_ROOT=File.join(Dir.pwd,"save_compatibility_fixture")
  ROUNDTRIP_ROOT=File.join(AzureEngineTest::SAVE_ROOT,"compatibility_roundtrip")
  ID_MODULES={
    "moves"=>PBMoves,
    "species"=>PBSpecies,
    "items"=>PBItems,
    "abilities"=>PBAbilities,
    "types"=>PBTypes,
    "trainer_types"=>PBTrainers
  }

  def self.write(rows)
    File.open(STATUS_PATH,"wb") {|file|
      for row in rows; file.write(row+"\r\n"); end
    }
  end

  def self.ensure_directory(path)
    Dir.mkdir(path) if !File.directory?(path)
  end

  def self.read_marshaled(path)
    objects=[]
    File.open(path,"rb") {|file|
      until file.eof?
        objects.push(Marshal.load(file))
      end
    }
    return objects
  end

  def self.effective_ids(mod)
    result={}
    for name in mod.constants(false)
      value=mod.const_get(name)
      result[name.to_s]=value if value.is_a?(Integer)
    end
    return result
  end

  def self.digest_rows(rows)
    require "digest"
    require "digest/sha2"
    return Digest::SHA256.hexdigest(rows.join("\n")+"\n").upcase
  end

  def self.pokemon_from(objects)
    result=[]
    trainer=objects[0]
    if trainer && trainer.respond_to?(:party)
      for pokemon in trainer.party
        result.push(pokemon) if pokemon
      end
    end
    storage=objects[14]
    if storage && storage.respond_to?(:maxBoxes) && storage.respond_to?(:maxPokemon)
      for box in 0...storage.maxBoxes
        for index in 0...storage.maxPokemon(box)
          pokemon=storage[box,index]
          result.push(pokemon) if pokemon
        end
      end
    end
    return result
  end

  def self.validate_pokemon(pokemon,known)
    return false if !known["species"].include?(pokemon.species)
    return false if pokemon.item && pokemon.item!=0 && !known["items"].include?(pokemon.item)
    for move in pokemon.moves
      next if !move || move.id==0
      return false if !known["moves"].include?(move.id)
    end
    if pokemon.respond_to?(:abilityoverride)
      ability=pokemon.abilityoverride
      return false if ability && ability!=0 && !known["abilities"].include?(ability)
    end
    return true
  end

  def self.run
    write(["result=RUNNING","phase=5_step_4_save_and_numeric_compatibility"])
    ensure_directory(AzureEngineTest::SAVE_ROOT)
    ensure_directory(ROUNDTRIP_ROOT)
    mappings={}
    known={}
    hashes={}
    counts={}
    for label,mod in ID_MODULES
      mapping=effective_ids(mod)
      rows=mapping.keys.sort.map {|name| "#{name}=#{mapping[name]}" }
      mappings[label]=mapping
      known[label]=mapping.values.uniq
      counts[label]=mapping.length
      hashes[label]=digest_rows(rows)
    end

    files=Dir.glob(File.join(FIXTURE_ROOT,"*.rxdata")).sort
    raise "No compatibility saves were packaged" if files.length==0
    failures=[]
    total_objects=0
    pokemon_checked=0
    maps={}
    started=Process.clock_gettime(Process::CLOCK_MONOTONIC)
    for path in files
      begin
        objects=read_marshaled(path)
        raise "expected 16 objects, found #{objects.length}" if objects.length!=16
        raise "trainer type changed" if !objects[0].is_a?(PokeBattle_Trainer)
        raise "frame count type changed" if !objects[1].is_a?(Numeric)
        raise "game system type changed" if !objects[2].is_a?(Game_System)
        raise "Pokemon system type changed" if !objects[3].is_a?(PokemonSystem)
        raise "map ID type changed" if !objects[4].is_a?(Numeric)
        map_id=objects[4].to_i
        raise "saved map #{map_id} is missing" if !pbRgssExists?(sprintf("Data/Map%03d.rxdata",map_id))
        maps[map_id]=true
        pokemon=pokemon_from(objects)
        for entry in pokemon
          raise "Pokemon numeric reference is unresolved" if !validate_pokemon(entry,known)
          pokemon_checked+=1
        end
        roundtrip_path=File.join(ROUNDTRIP_ROOT,File.basename(path))
        File.open(roundtrip_path,"wb") {|file|
          for object in objects; Marshal.dump(object,file); end
        }
        roundtrip=read_marshaled(roundtrip_path)
        raise "round-trip object count changed" if roundtrip.length!=objects.length
        raise "round-trip class sequence changed" if roundtrip.map {|item| item.class }!=objects.map {|item| item.class }
        raise "round-trip trainer changed" if roundtrip[0].name!=objects[0].name
        raise "round-trip map changed" if roundtrip[4]!=objects[4]
        total_objects+=objects.length
      rescue Exception
        failures.push("#{File.basename(path)}:#{$!.class}:#{$!.message}")
      end
    end
    elapsed=Process.clock_gettime(Process::CLOCK_MONOTONIC)-started
    result=(failures.length==0 && total_objects==files.length*16 && pokemon_checked>0)
    rows=[
      "result=#{result ? 'PASS' : 'FAIL'}",
      "phase=5_step_4_save_and_numeric_compatibility",
      "save_files=#{files.length}",
      "save_files_passed=#{files.length-failures.length}",
      "save_files_failed=#{failures.length}",
      "marshal_objects=#{total_objects}",
      "saved_maps=#{maps.keys.sort.join(',')}",
      "pokemon_checked=#{pokemon_checked}",
      "numeric_references_resolved=#{failures.length==0}",
      "roundtrip_scope=isolated_package_only",
      "roundtrip_class_sequences_exact=#{failures.length==0}",
      "compatibility_seconds=#{elapsed}",
      "probe_errors=#{failures.length==0 ? 'none' : failures.join(' | ')}"
    ]
    for label in ID_MODULES.keys
      rows.push("#{label}_id_count=#{counts[label]}")
      rows.push("#{label}_id_sha256=#{hashes[label]}")
    end
    write(rows)
    raise "Compatibility fixture failed: #{failures.join(' | ')}" if !result
    return true
  rescue Exception
    detail="#{$!.class}: #{$!.message}"
    detail+=" | #{$!.backtrace[0,8].join(' <- ')}" if $!.backtrace
    write(["result=FAIL","phase=5_step_4_save_and_numeric_compatibility","error=#{detail}"])
    raise
  end
end

AzureReleaseCompatibilityFixture.run
