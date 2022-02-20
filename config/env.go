package config

import (
	"log"
	"sync"

	"github.com/spf13/viper"
)

type AppEnvValue string

const (
	Development AppEnvValue = "dev"
	Staging     AppEnvValue = "staging"
	Production  AppEnvValue = "prod"
)

type Config struct {
	AppEnv    AppEnvValue `mapstructure:"env"`
	PageTitle string      `mapstructure:"pageTitle"`
	PageDesc  string      `mapstructure:"pageDesc"`
}

var (
	lock           = &sync.Mutex{}
	config *Config = nil
)

func GetConfig() *Config {
	if config != nil {
		// go appConfig.loadFromDB()
		return config
	}

	lock.Lock()
	defer lock.Unlock()

	//re-check after locking
	if config != nil {
		return config
	}

	config = initConfig()

	return config
}

func defaultConfig() *Config {
	var defaultConfig Config

	defaultConfig.AppEnv = Development
	defaultConfig.PageTitle = ""
	defaultConfig.PageDesc = ""

	return &defaultConfig
}

func initConfig() *Config {
	defaultCfg := defaultConfig()

	// only essential config gathered from .env, other else from DB
	viper.AutomaticEnv()
	viper.SetEnvPrefix("app")

	viper.SetDefault("env", defaultCfg.AppEnv)
	viper.SetDefault("pageTitle", defaultCfg.PageTitle)
	viper.SetDefault("pageDesc", defaultCfg.PageDesc)

	viper.BindEnv("env")
	viper.BindEnv("pageTitle")
	viper.BindEnv("pageDesc")

	var cfg Config

	// Base config still read from .env file. Such as main database connection that keep other App Configuration
	err := viper.Unmarshal(&cfg)
	if err != nil {
		log.Fatal(err)
		return defaultCfg
	}

	return &cfg
}
