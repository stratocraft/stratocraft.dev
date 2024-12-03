// Code generated by templ - DO NOT EDIT.

// templ: version: 0.2.476
package icons

//lint:file-ignore SA4006 This context is only used if a nested component is present.

import "github.com/a-h/templ"
import "context"
import "io"
import "bytes"

func Ansible() templ.Component {
	return templ.ComponentFunc(func(ctx context.Context, templ_7745c5c3_W io.Writer) (templ_7745c5c3_Err error) {
		templ_7745c5c3_Buffer, templ_7745c5c3_IsBuffer := templ_7745c5c3_W.(*bytes.Buffer)
		if !templ_7745c5c3_IsBuffer {
			templ_7745c5c3_Buffer = templ.GetBuffer()
			defer templ.ReleaseBuffer(templ_7745c5c3_Buffer)
		}
		ctx = templ.InitializeContext(ctx)
		templ_7745c5c3_Var1 := templ.GetChildren(ctx)
		if templ_7745c5c3_Var1 == nil {
			templ_7745c5c3_Var1 = templ.NopComponent
		}
		ctx = templ.ClearChildren(ctx)
		_, templ_7745c5c3_Err = templ_7745c5c3_Buffer.WriteString("<div class=\"brand-icon-block\" title=\"Ansible\"><svg class=\"w-10\" xmlns=\"http://www.w3.org/2000/svg\" viewBox=\"0 0 24 24\"><path fill=\"currentColor\" d=\"m10.617 11.473l4.686 3.695l-3.102-7.662zM12 0C5.371 0 0 5.371 0 12s5.371 12 12 12s12-5.371 12-12S18.629 0 12 0m5.797 17.305a.851.851 0 0 1-.875.83c-.236 0-.416-.09-.664-.293l-6.19-5l-2.079 5.203H6.191L11.438 5.44a.79.79 0 0 1 .764-.506a.756.756 0 0 1 .742.506l4.774 11.494c.045.111.08.234.08.348z\"></path></svg></div>")
		if templ_7745c5c3_Err != nil {
			return templ_7745c5c3_Err
		}
		if !templ_7745c5c3_IsBuffer {
			_, templ_7745c5c3_Err = templ_7745c5c3_Buffer.WriteTo(templ_7745c5c3_W)
		}
		return templ_7745c5c3_Err
	})
}