#ifdef EMSCRIPTEN

#include "js-interface.hpp"
#include "importer-step.hpp"
#include "importer-iges.hpp"
#include "importer-brep.hpp"
#include <emscripten/bind.h>

class HierarchyWriter
{
public:
    HierarchyWriter (emscripten::val& meshesArr) :
        mMeshesArr (meshesArr),
        mMeshCount (0)
    {}

    void WriteNode (const NodePtr& node, emscripten::val& nodeObj)
    {
        nodeObj.set ("name", node->GetName ());

        emscripten::val nodeMeshesArr (emscripten::val::array ());
        WriteMeshes (node, nodeMeshesArr);
        nodeObj.set ("meshes", nodeMeshesArr);

        std::vector<NodePtr> children = node->GetChildren ();
        emscripten::val childrenArr (emscripten::val::array ());
        for (int childIndex = 0; childIndex < children.size (); childIndex++) {
            const NodePtr& child = children[childIndex];
            emscripten::val childNodeObj (emscripten::val::object ());
            WriteNode (child, childNodeObj);
            childrenArr.set (childIndex, childNodeObj);
        }
        nodeObj.set ("children", childrenArr);
    }

private:
    void WriteMeshes (const NodePtr& node, emscripten::val& nodeMeshesArr)
    {
        if (!node->IsMeshNode ()) {
            return;
        }

        int nodeMeshCount = 0;
        node->EnumerateMeshes ([&](const Mesh& mesh) {
            emscripten::val meshObj (emscripten::val::object ());
            meshObj.set ("name", mesh.GetName ());

            int vertexCount = 0;
            int normalCount = 0;
            int triangleCount = 0;
            int brepFaceCount = 0;
            int uvCount = 0;
            int uv2Count = 0;

            emscripten::val positionArr (emscripten::val::array ());
            emscripten::val normalArr (emscripten::val::array ());
            emscripten::val indexArr (emscripten::val::array ());
            emscripten::val brepFaceArr (emscripten::val::array ());
            emscripten::val uvArr (emscripten::val::array ());

            mesh.EnumerateFaces ([&](const Face& face) {
                int triangleOffset = triangleCount;
                int vertexOffset = vertexCount;
                face.EnumerateVertices ([&](double x, double y, double z) {
                    positionArr.set (vertexCount * 3, x);
                    positionArr.set (vertexCount * 3 + 1, y);
                    positionArr.set (vertexCount * 3 + 2, z);
                    vertexCount += 1;
                });
                face.EnumerateNormals ([&](double x, double y, double z) {
                    normalArr.set (normalCount * 3, x);
                    normalArr.set (normalCount * 3 + 1, y);
                    normalArr.set (normalCount * 3 + 2, z);
                    normalCount += 1;
                });
                face.EnumerateTriangles ([&](int v0, int v1, int v2) {
                    indexArr.set (triangleCount * 3, vertexOffset + v0);
                    indexArr.set (triangleCount * 3 + 1, vertexOffset + v1);
                    indexArr.set (triangleCount * 3 + 2, vertexOffset + v2);
                    triangleCount += 1;
                });
                face.EnumerateUVs ([&](double u, double v) {
                    uvArr.set (uvCount * 2, u);
                    uvArr.set (uvCount * 2 + 1, v);
                    uvCount += 1;
                });
                emscripten::val brepFaceObj (emscripten::val::object ());
                brepFaceObj.set ("first", triangleOffset);
                brepFaceObj.set ("last", triangleCount - 1);
                Color faceColor;
                if (face.GetColor (faceColor)) {
                    emscripten::val colorArr (emscripten::val::array ());
                    colorArr.set (0, faceColor.r);
                    colorArr.set (1, faceColor.g);
                    colorArr.set (2, faceColor.b);
                    brepFaceObj.set ("color", colorArr);
                } else {
                    brepFaceObj.set ("color", emscripten::val::null ());
                }
                brepFaceArr.set (brepFaceCount, brepFaceObj);
                brepFaceCount += 1;
            });

            emscripten::val attributesObj (emscripten::val::object ());

            emscripten::val positionObj (emscripten::val::object ());
            positionObj.set ("array", positionArr);
            attributesObj.set ("position", positionObj);

            if (vertexCount == normalCount) {
                emscripten::val normalObj (emscripten::val::object ());
                normalObj.set ("array", normalArr);
                attributesObj.set ("normal", normalObj);
            }

            emscripten::val uvObj (emscripten::val::object ());
            uvObj.set ("array", uvArr);
            attributesObj.set ("uv", uvObj);

            emscripten::val indexObj (emscripten::val::object ());
            indexObj.set ("array", indexArr);

            meshObj.set ("attributes", attributesObj);
            meshObj.set ("index", indexObj);

            Color meshColor;
            if (mesh.GetColor (meshColor)) {
                emscripten::val colorArr (emscripten::val::array ());
                colorArr.set (0, meshColor.r);
                colorArr.set (1, meshColor.g);
                colorArr.set (2, meshColor.b);
                meshObj.set ("color", colorArr);
            }

            meshObj.set ("brep_faces", brepFaceArr);

            mMeshesArr.set (mMeshCount, meshObj);
            nodeMeshesArr.set (nodeMeshCount, mMeshCount);
            mMeshCount += 1;
            nodeMeshCount += 1;
        });
    }

    emscripten::val& mMeshesArr;
    int mMeshCount;
};
#endif
