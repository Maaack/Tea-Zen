extends Node

const PERSISTENT_SECTION = "PersistentData"
const REMEMBERED_INTROS = "RememberedIntros"
const REMEMBERED_OUTROS = "RememberedOutros"
const REMEMBERED_STEEPINGS = "RememberedSteepings"
const REMEMBERED_RETURNS = "RememberedReturns"
const REMEMBERED_SKIPPED_INTROS = "RememberedSkippedIntros"
const REMEMBERED_MIXED_TEAS = "RememberedMixedTeas"
const REMEMBERED_TIME_PLAYED = "RememberedTimePlayed"
const TOTAL_INTROS = "TotalIntros"
const TOTAL_OUTROS = "TotalOutros"
const TOTAL_STEEPINGS = "TotalSteepings"
const TOTAL_RETURNS = "TotalReturns"
const TOTAL_SKIPPED_INTROS = "TotalSkippedIntros"
const TOTAL_MIXED_TEAS = "TotalMixedTeas"
const TOTAL_TIME_PLAYED = "TotalTimePlayed"
const FIRST_VERSION_PLAYED = "FirstVersionPlayed"
const UPDATE_COUNTER_RESET = 3.0
const UNKNOWN_VERSION = "unknown"

var remembered_intros : int = 0
var remembered_outros : int = 0
var remembered_steepings : int = 0
var remembered_returns : int = 0
var remembered_skipped_intros : int = 0
var remembered_mixed_teas : int = 0
var remembered_time_played : float = 0.0
var total_intros : int = 0
var total_outros : int = 0
var total_steepings : int = 0
var total_returns : int = 0
var total_skipped_intros : int = 0
var total_mixed_teas : int = 0
var total_time_played : float = 0.0
var first_version_played : String = UNKNOWN_VERSION setget set_first_version_played
var update_counter : float = 0.0

func _process(delta):
	remembered_time_played += delta
	total_time_played += delta
	update_counter += delta
	if update_counter > UPDATE_COUNTER_RESET:
		update_counter = 0.0
		Config.set_config(PERSISTENT_SECTION, REMEMBERED_TIME_PLAYED, remembered_time_played)
		Config.set_config(PERSISTENT_SECTION, TOTAL_TIME_PLAYED, total_time_played)

func _sync_with_config() -> void:
	remembered_intros = Config.get_config(PERSISTENT_SECTION, REMEMBERED_INTROS, remembered_intros)
	remembered_outros = Config.get_config(PERSISTENT_SECTION, REMEMBERED_OUTROS, remembered_outros)
	remembered_steepings = Config.get_config(PERSISTENT_SECTION, REMEMBERED_STEEPINGS, remembered_steepings)
	remembered_returns = Config.get_config(PERSISTENT_SECTION, REMEMBERED_RETURNS, remembered_returns)
	remembered_skipped_intros = Config.get_config(PERSISTENT_SECTION, REMEMBERED_SKIPPED_INTROS, remembered_skipped_intros)
	remembered_mixed_teas = Config.get_config(PERSISTENT_SECTION, REMEMBERED_MIXED_TEAS, remembered_mixed_teas)
	remembered_time_played = Config.get_config(PERSISTENT_SECTION, REMEMBERED_TIME_PLAYED, remembered_time_played)
	total_intros = Config.get_config(PERSISTENT_SECTION, TOTAL_INTROS, total_intros)
	total_outros = Config.get_config(PERSISTENT_SECTION, TOTAL_OUTROS, total_outros)
	total_steepings = Config.get_config(PERSISTENT_SECTION, TOTAL_STEEPINGS, total_steepings)
	total_returns = Config.get_config(PERSISTENT_SECTION, TOTAL_RETURNS, total_returns)
	total_time_played = Config.get_config(PERSISTENT_SECTION, TOTAL_TIME_PLAYED, total_time_played)
	total_skipped_intros = Config.get_config(PERSISTENT_SECTION, TOTAL_SKIPPED_INTROS, total_skipped_intros)
	total_mixed_teas = Config.get_config(PERSISTENT_SECTION, TOTAL_MIXED_TEAS, total_mixed_teas)
	first_version_played = Config.get_config(PERSISTENT_SECTION, FIRST_VERSION_PLAYED, first_version_played)

func _init():
	_sync_with_config()

func played_intro():
	remembered_intros += 1
	total_intros += 1
	Config.set_config(PERSISTENT_SECTION, REMEMBERED_INTROS, remembered_intros)
	Config.set_config(PERSISTENT_SECTION, TOTAL_INTROS, total_intros)

func played_steeping():
	remembered_steepings += 1
	total_steepings += 1
	Config.set_config(PERSISTENT_SECTION, REMEMBERED_STEEPINGS, remembered_steepings)
	Config.set_config(PERSISTENT_SECTION, TOTAL_STEEPINGS, total_steepings)

func played_return():
	remembered_returns += 1
	total_returns += 1
	Config.set_config(PERSISTENT_SECTION, REMEMBERED_RETURNS, remembered_returns)
	Config.set_config(PERSISTENT_SECTION, TOTAL_RETURNS, total_returns)

func skipped_intro():
	remembered_skipped_intros += 1
	total_skipped_intros += 1
	Config.set_config(PERSISTENT_SECTION, REMEMBERED_SKIPPED_INTROS, remembered_skipped_intros)
	Config.set_config(PERSISTENT_SECTION, TOTAL_SKIPPED_INTROS, total_skipped_intros)

func mixed_teas():
	remembered_mixed_teas += 1
	total_mixed_teas += 1
	Config.set_config(PERSISTENT_SECTION, REMEMBERED_MIXED_TEAS, remembered_mixed_teas)
	Config.set_config(PERSISTENT_SECTION, TOTAL_MIXED_TEAS, total_mixed_teas)

func played_outro():
	remembered_outros += 1
	total_outros += 1
	Config.set_config(PERSISTENT_SECTION, REMEMBERED_OUTROS, remembered_outros)
	Config.set_config(PERSISTENT_SECTION, TOTAL_OUTROS, total_outros)

func reset_memory():
	remembered_intros = 0
	remembered_outros = 0
	remembered_steepings = 0
	remembered_returns = 0
	remembered_skipped_intros = 0
	remembered_mixed_teas = 0
	remembered_time_played = 0.0
	Config.set_config(PERSISTENT_SECTION, REMEMBERED_INTROS, remembered_intros)
	Config.set_config(PERSISTENT_SECTION, REMEMBERED_OUTROS, remembered_outros)
	Config.set_config(PERSISTENT_SECTION, REMEMBERED_STEEPINGS, remembered_steepings)
	Config.set_config(PERSISTENT_SECTION, REMEMBERED_RETURNS, remembered_returns)
	Config.set_config(PERSISTENT_SECTION, REMEMBERED_SKIPPED_INTROS, remembered_skipped_intros)
	Config.set_config(PERSISTENT_SECTION, REMEMBERED_MIXED_TEAS, remembered_mixed_teas)
	Config.set_config(PERSISTENT_SECTION, REMEMBERED_TIME_PLAYED, remembered_time_played)

func set_first_version_played(value : String) -> void:
	if first_version_played != UNKNOWN_VERSION:
		return
	first_version_played = value
	Config.set_config(PERSISTENT_SECTION, FIRST_VERSION_PLAYED, first_version_played)
