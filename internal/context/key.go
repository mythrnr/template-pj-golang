package context

type key struct {
	value string
}

func (k *key) String() string {
	return k.value
}
