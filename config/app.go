package config

import (
	"os"
	"strconv"

	validation "github.com/go-ozzo/ozzo-validation/v4"
	"github.com/pkg/errors"
)

// AllowedMinPort はウェルノウンポート（ 0-1023 ）を
// 使用させないようにするために指定するポート番号の最低値.
const AllowedMinPort uint16 = 1024

const (
	// EnvProduction は本番環境を示す環境変数値.
	EnvProduction = "production"

	// EnvTesting は検証環境を示す環境変数値.
	EnvTesting = "testing"

	// EnvDevelopment は開発環境を示す環境変数値.
	EnvDevelopment = "development"

	// EnvLocal はローカル環境を示す環境変数値.
	EnvLocal = "local"
)

const (
	// LogLevelDebug はデバッグ情報を出力させるための設定値.
	LogLevelDebug = "debug"

	// LogLevelInfo は情報を出力させるための設定値.
	LogLevelInfo = "info"

	// LogLevelWarning は警告情報を出力させるための設定値.
	LogLevelWarning = "warning"

	// LogLevelError はエラー情報を出力させるための設定値.
	LogLevelError = "error"

	// LogLevelFatal は致命的なエラー情報を出力させるための設定値.
	LogLevelFatal = "fatal"
)

func (c *Config) bindApp() error {
	if v := ts(os.Getenv("APP_ENV")); v != "" {
		c.App.Env = v
	}

	if v := ts(os.Getenv("APP_LISTEN_PORT")); v != "" {
		if v, err := strconv.ParseUint(v, 10, 16); err != nil {
			return errors.WithStack(err)
		} else if v != 0 {
			c.App.ListenPort = uint16(v)
		}
	}

	if v := ts(os.Getenv("APP_LOG_LEVEL")); v != "" {
		c.App.LogLevel = v
	}

	return validation.Errors{
		"app.env": validation.Validate(
			c.App.Env,
			validation.Required,
			validation.In(
				EnvProduction,
				EnvTesting,
				EnvDevelopment,
				EnvLocal,
			),
		),
		"app.listen_port": validation.Validate(
			int64(c.App.ListenPort),
			validation.Required,
			validation.
				Min(int64(AllowedMinPort)).
				Error("must not be well know ports"),
		),
		"app.log_level": validation.Validate(
			c.App.LogLevel,
			validation.Required,
			validation.In(
				LogLevelDebug,
				LogLevelInfo,
				LogLevelWarning,
				LogLevelError,
				LogLevelFatal,
			),
		),
	}.Filter()
}
