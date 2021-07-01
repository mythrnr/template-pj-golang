/*
Package myproject is the root package of this project.

Package myproject はこのプロジェクトのルートパッケージ.

- Not putting it directly on this package except embed files.

- 埋め込みファイルを除き, このパッケージには直接置かない.
*/
// nolint:gochecknoglobals
package myproject

import "embed"

//go:embed configs/config.yml
//go:embed configs/lang/*.json
// Files includes configuration files.
var Files embed.FS

// Version is the value of release tag embed on build.
//
// Version はビルド時に埋め込まれるリリースタグの値.
var Version = "edge"

// Revision is the value of commit hash embed on build.
//
// Revision はビルド時に埋め込まれるコミットハッシュの値.
var Revision = "latest"
