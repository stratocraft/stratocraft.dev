package contentmanager

import (
	"bytes"
	"github.com/microcosm-cc/bluemonday"
	"github.com/russross/blackfriday/v2"
	"github.com/spf13/viper"
	"regexp"
	"strings"
	"time"
)

func parseMarkdown(content string) (Post, error) {
	frontMatter, body, err := parseFrontMatter([]byte(content))
	if err != nil {
		return Post{}, err
	}

	html, err := markdownToHtml([]byte(body))
	if err != nil {
		return Post{}, err
	}

	return Post{
		ID:          frontMatter.ID,
		Date:        frontMatter.Date,
		DisplayDate: frontMatter.Date.Format(time.RFC3339),
		Title:       frontMatter.Title,
		Content:     html,
		RawContent:  body,
		Slug:        frontMatter.Slug,
		Tags:        frontMatter.Tags,
		Published:   frontMatter.Published,
	}, nil
}

func parseFrontMatter(markdown []byte) (FrontMatter, string, error) {
	parts := strings.SplitN(string(markdown), "---", 3)
	if len(parts) < 3 {
		return FrontMatter{}, string(markdown), nil
	}

	v := viper.New()
	v.SetConfigType("yaml")
	if err := v.ReadConfig(bytes.NewBufferString(parts[1])); err != nil {
		return FrontMatter{}, "", err
	}

	var fm FrontMatter
	if err := v.Unmarshal(&fm); err != nil {
		return FrontMatter{}, "", err
	}

	return fm, parts[2], nil
}

func markdownToHtml(markdown []byte) (string, error) {
	output := blackfriday.Run(markdown)
	p := bluemonday.UGCPolicy()
	p.AllowAttrs("class").Matching(regexp.MustCompile("^language-[a-zA-Z0-9]+$")).OnElements("code")
	p.RequireParseableURLs(true)
	p.AddTargetBlankToFullyQualifiedLinks(true)

	return string(p.SanitizeBytes(output)), nil
}
