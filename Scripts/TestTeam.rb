#===============================================================================
# Tester PBS Team Picker
# - Uses trainer type PBTrainers::TESTER as the pool of available teams
# - Any player can open it
# - Shows a scrollable list (trainer names), selecting one overwrites player's party
#===============================================================================

def pbTesterTeamMenu
  unless defined?(PBTrainers) && PBTrainers.const_defined?(:TESTER)
    Kernel.pbMessage(_INTL("PBTrainers::TESTER isn't defined."))
    return false
  end

  # Load compiled trainers
  trainers_data = nil
  begin
    trainers_data = load_data("Data/trainers.dat")
  rescue
    Kernel.pbMessage(_INTL("Couldn't load Data/trainers.dat. Compile Trainers first."))
    return false
  end

  tester_type = PBTrainers::TESTER

  # Get all candidate names under TESTER in the simplest possible way
  candidate_names = pbGetTrainerNamesForType_Simple(trainers_data, tester_type)

  # Validate names by actually trying to load them (avoids garbage/empty entries)
  names = []
  candidate_names.each do |nm|
    next if !nm || nm.to_s.strip.empty?
    next if nm.to_s == "???"
    if pbTrainerEntryExists?(tester_type, nm, 0)
      names << nm.to_s
    end
  end
  names.uniq!
  names.sort_by! { |n| n.downcase }

  if names.empty?
    Kernel.pbMessage(_INTL("No TESTER teams found.\nMake sure Trainers are compiled and the PBS has TESTER entries."))
    return false
  end

  # UI list
  cmd = names + [_INTL("Cancel")]
  chosen = Kernel.pbShowCommands(nil, cmd, -1)
  return false if chosen.nil? || chosen < 0 || chosen >= names.length

  team_name = names[chosen]
  pbApplyTrainerTeamToPlayer(tester_type, team_name, 0)
  return true
end

#-------------------------------------------------------------------------------
# Extract names for a trainer type from trainers.dat in multiple common shapes.
# This is intentionally "simple": just try several patterns and union results.
#-------------------------------------------------------------------------------
def pbGetTrainerNamesForType_Simple(trainers_data, trainer_type_id)
  out = []

  # Pattern 1: Array indexed by type, then Hash keyed by name
  begin
    if trainers_data.is_a?(Array) && trainers_data[trainer_type_id].is_a?(Hash)
      out.concat(trainers_data[trainer_type_id].keys)
    end
  rescue
  end

  # Pattern 2: Hash keyed by trainer_type_id -> Hash(name => ...)
  begin
    if trainers_data.is_a?(Hash) && trainers_data[trainer_type_id].is_a?(Hash)
      out.concat(trainers_data[trainer_type_id].keys)
    end
  rescue
  end

  # Pattern 3: Flat Hash keyed by [type, name] or [type, name, version]
  begin
    if trainers_data.is_a?(Hash)
      trainers_data.keys.each do |k|
        next unless k.is_a?(Array)
        next unless k.length >= 2
        next unless k[0] == trainer_type_id
        out << k[1]
      end
    end
  rescue
  end

  # Pattern 4: Some kits store an array of trainer records, each has trainertype/name
  begin
    if trainers_data.is_a?(Array)
      trainers_data.each do |entry|
        next if entry.nil?
        if entry.respond_to?(:trainertype) && entry.respond_to?(:name)
          out << entry.name if entry.trainertype == trainer_type_id
        elsif entry.is_a?(Array) && entry.length >= 2
          # very loose fallback: [type, name, ...]
          out << entry[1] if entry[0] == trainer_type_id
        end
      end
    end
  rescue
  end

  out.compact!
  out.map! { |x| x.to_s }
  out.uniq!
  return out
end

#-------------------------------------------------------------------------------
# True if pbLoadTrainer can load the given trainer entry (type/name/version)
#-------------------------------------------------------------------------------
def pbTrainerEntryExists?(trainer_type_id, trainer_name, version=0)
  return false if trainer_name.nil? || trainer_name.to_s.strip.empty?
  begin
    loaded = pbLoadTrainer(trainer_type_id, trainer_name, version)
    # Common returns: [trainer, items, party] or [trainer, party]
    return false if loaded.nil?
    if loaded.is_a?(Array)
      party = nil
      party = loaded[2] if loaded.length >= 3
      party = loaded[1] if party.nil? && loaded[1].is_a?(Array)
      return party.is_a?(Array) && party.length > 0
    end
    return true
  rescue
    return false
  end
end

#-------------------------------------------------------------------------------
# Overwrite player's party with trainer's party from trainers.dat (via pbLoadTrainer)
#-------------------------------------------------------------------------------
def pbApplyTrainerTeamToPlayer(trainer_type_id, trainer_name, version=0)
  loaded = pbLoadTrainer(trainer_type_id, trainer_name, version)
  party = nil

  if loaded.is_a?(Array)
    party = loaded[2] if loaded.length >= 3
    party = loaded[1] if party.nil? && loaded[1].is_a?(Array)
  end

  if !party.is_a?(Array) || party.empty?
    Kernel.pbMessage(_INTL("Failed to load party for {1}.", trainer_name))
    return false
  end

  new_party = []
  party.each do |pkmn|
    break if new_party.length >= 6
    next if pkmn.nil?

    begin
      mon = pkmn.clone
    rescue
      mon = pkmn
    end

    # Make them "yours" (helps with some OT-based systems)
    begin
      mon.trainerID = $Trainer.id if mon.respond_to?(:trainerID=)
      mon.ot = $Trainer.name if mon.respond_to?(:ot=)
    rescue
    end
    begin
      mon.heal if mon.respond_to?(:heal)
    rescue
    end

    new_party << mon
  end

  $Trainer.party.clear
  new_party.each { |m| $Trainer.party << m }

  Kernel.pbMessage(_INTL("Loaded TESTER team: {1}", trainer_name))
  return true
end
