package context

import "context"

// nolint:gochecknoglobals
var _contextKeyValue = &key{"_contextKeyValue"}

// GetValue は引数の `context` から値を取得する.
func GetValue(ctx context.Context) int {
	value, ok := ctx.Value(_contextKeyValue).(int)
	if ok {
		return value
	}

	return 0
}

// SetValue は引数の `context` を親として値を設定した新たな `context` を返す.
func SetValue(ctx context.Context, value int) context.Context {
	return context.WithValue(ctx, _contextKeyValue, value)
}
